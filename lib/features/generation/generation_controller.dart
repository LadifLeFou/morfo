import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_state.dart';
import '../../core/app_exception.dart';
import '../../core/models/generation_result.dart';
import '../../core/models/template.dart';
import '../../services/generation_service.dart';
import '../../services/service_providers.dart';

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
  }) async {
    _cancelled = false;
    state = const GenRunning();
    final GenerationService service = ref.read(generationServiceProvider);
    final String userId = ref.read(appUserIdProvider);

    try {
      final GenerationResult result = template.isVideo
          ? await _runVideo(service, template, bytes, userId, sourcePath)
          : await _runImage(service, template, bytes, userId, sourcePath);

      if (_cancelled) return;
      ref.read(historyProvider.notifier).add(result);
      state = GenDone(result);
    } on AppException catch (e) {
      if (_cancelled) return;
      state = GenError(e.message, insufficientCredits: e.insufficientCredits);
    } catch (_) {
      if (_cancelled) return;
      state = const GenError('La génération a échoué. Réessaie.');
    }
  }

  Future<GenerationResult> _runImage(
    GenerationService service,
    Template template,
    Uint8List bytes,
    String userId,
    String? sourcePath,
  ) async {
    final GenerationOutcome outcome = await service.generateImage(
      template: template,
      imageBytes: bytes,
      userId: userId,
      sourcePath: sourcePath,
    );
    ref.read(creditsProvider.notifier).applyOutcome(
          template.creditCost,
          outcome.creditsLeft,
        );
    return outcome.result;
  }

  Future<GenerationResult> _runVideo(
    GenerationService service,
    Template template,
    Uint8List bytes,
    String userId,
    String? sourcePath,
  ) async {
    final String requestId = await service.submitVideo(
      template: template,
      imageBytes: bytes,
      userId: userId,
    );

    // Polling jusqu'à complétion ou échec.
    while (!_cancelled) {
      final VideoStatus status = await service.pollVideo(requestId);
      if (status.phase == VideoPhase.completed) {
        ref.read(creditsProvider.notifier).applyOutcome(template.creditCost, -1);
        return GenerationResult(
          id: requestId,
          templateId: template.id,
          templateTitle: template.title,
          category: template.category,
          outputUrl: status.url ?? 'morfo://demo/video/$requestId',
          kind: template.kind,
          createdAt: DateTime.now(),
          sourcePath: sourcePath,
        );
      }
      if (status.phase == VideoPhase.failed) {
        throw const AppException('La génération a échoué. Réessaie.');
      }
    }
    throw const AppException('Génération annulée.');
  }
}

final NotifierProvider<GenerationController, GenState>
    generationControllerProvider =
    NotifierProvider<GenerationController, GenState>(GenerationController.new);
