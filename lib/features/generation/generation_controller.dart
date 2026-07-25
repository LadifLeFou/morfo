import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_state.dart';
import '../../core/app_exception.dart';
import '../../core/models/generation_result.dart';
import '../../core/models/template.dart';
import '../../services/generation_service.dart';
import '../../services/result_cache.dart';
import '../../services/service_providers.dart';
import '../../core/strings.dart';

/// État d'une génération en cours.
sealed class GenState {
  const GenState();
}

class GenIdle extends GenState {
  const GenIdle();
}

class GenRunning extends GenState {
  const GenRunning();
}

class GenDone extends GenState {
  const GenDone(this.result);
  final GenerationResult result;
}

class GenError extends GenState {
  const GenError(this.message, {this.insufficientCredits = false});
  final String message;
  final bool insufficientCredits;
}

/// Pilote une génération (image synchrone ; vidéo = submit + polling).
class GenerationController extends Notifier<GenState> {
  bool _cancelled = false;

  @override
  GenState build() => const GenIdle();

  void reset() {
    _cancelled = false;
    state = const GenIdle();
  }

  void cancel() {
    _cancelled = true;
    state = const GenIdle();
  }

  Future<void> run({
    required Template template,
    required Uint8List bytes,
    String? sourcePath,
    String? customPrompt,
  }) async {
    _cancelled = false;
    state = const GenRunning();
    final GenerationService service = ref.read(generationServiceProvider);
    final String userId = ref.read(appUserIdProvider);

    try {
      final GenerationResult result = template.isVideo
          ? await _runVideo(
              service, template, bytes, userId, sourcePath, customPrompt)
          : await _runImage(
              service, template, bytes, userId, sourcePath, customPrompt);

      if (_cancelled) return;
      ref.read(historyProvider.notifier).add(result);
      state = GenDone(result);
      // Copie locale en tâche de fond : l'URL distante expire, la création doit
      // rester visible dans l'historique. On n'attend pas — l'écran résultat
      // s'affiche déjà avec l'URL fraîche.
      _cacheResult(result);
    } on AppException catch (e) {
      if (_cancelled) return;
      state = GenError(e.message, insufficientCredits: e.insufficientCredits);
    } catch (_) {
      if (_cancelled) return;
      state = GenError(S.genFailed);
    }
  }

  Future<GenerationResult> _runImage(
    GenerationService service,
    Template template,
    Uint8List bytes,
    String userId,
    String? sourcePath,
    String? customPrompt,
  ) async {
    final GenerationOutcome outcome = await service.generateImage(
      template: template,
      imageBytes: bytes,
      userId: userId,
      sourcePath: sourcePath,
      customPrompt: customPrompt,
    );
    ref.read(creditsProvider.notifier).applyOutcome(
          template.creditCost,
          outcome.creditsLeft,
        );
    return outcome.result;
  }

  /// Télécharge la copie locale du résultat sans bloquer l'UI, puis rattache
  /// son chemin à l'entrée d'historique. Silencieux en cas d'échec (web,
  /// réseau) : on garde alors l'URL distante.
  Future<void> _cacheResult(GenerationResult result) async {
    if (result.isVideo) return; // vidéos non cachées (volumineuses, rares)
    final String? path =
        await cacheResultImage(result.outputUrl, result.id);
    if (path != null) {
      ref.read(historyProvider.notifier).setLocalPath(result.id, path);
    }
  }

  Future<GenerationResult> _runVideo(
    GenerationService service,
    Template template,
    Uint8List bytes,
    String userId,
    String? sourcePath,
    String? customPrompt,
  ) async {
    final String requestId = await service.submitVideo(
      template: template,
      imageBytes: bytes,
      userId: userId,
      customPrompt: customPrompt,
    );

    // Polling borné : la vidéo prend 1-3 min, on plafonne à 6 min pour ne pas
    // sonder indéfiniment si le serveur reste bloqué. On tolère quelques
    // erreurs réseau d'affilée plutôt que de tuer une génération payée sur un
    // simple hoquet.
    const int maxPolls = 120; // 120 × 3 s = 6 min
    const int maxConsecutiveErrors = 5;
    int errors = 0;

    for (int i = 0; i < maxPolls && !_cancelled; i++) {
      await Future<void>.delayed(const Duration(seconds: 3));
      if (_cancelled) break;

      final VideoStatus status;
      try {
        status = await service.pollVideo(requestId);
        errors = 0;
      } on AppException {
        if (++errors >= maxConsecutiveErrors) rethrow;
        continue;
      }

      if (status.phase == VideoPhase.completed) {
        ref.read(creditsProvider.notifier).applyOutcome(template.creditCost, -1);
        return GenerationResult(
          id: requestId,
          templateId: template.id,
          templateTitle: template.displayTitle,
          category: template.category,
          outputUrl: status.url ?? 'morfo://demo/video/$requestId',
          kind: template.kind,
          createdAt: DateTime.now(),
          sourcePath: sourcePath,
        );
      }
      if (status.phase == VideoPhase.failed) {
        throw AppException(S.genFailed);
      }
    }
    // Sortie de boucle sans résultat : annulation ou délai dépassé.
    throw AppException(_cancelled ? S.genCancelled : S.genFailed);
  }
}

final NotifierProvider<GenerationController, GenState>
    generationControllerProvider =
    NotifierProvider<GenerationController, GenState>(GenerationController.new);
