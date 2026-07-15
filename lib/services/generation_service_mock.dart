import 'dart:math';
import 'dart:typed_data';

import '../core/app_exception.dart';
import '../core/models/generation_result.dart';
import '../core/models/template.dart';
import '../data/demo_templates.dart';
import 'generation_service.dart';

/// Service de démonstration : renvoie des résultats crédibles sans backend.
///
/// Permet de lancer l'app end-to-end immédiatement (flag [Env.useMock]).
class MockGenerationService implements GenerationService {
  MockGenerationService();

  final Random _rng = Random();
  final Map<String, DateTime> _videoJobs = <String, DateTime>{};

  @override
  Future<List<Template>> fetchTemplates() async {
    await Future<void>.delayed(const Duration(milliseconds: 650));
    return demoTemplates;
  }

  @override
  Future<GenerationOutcome> generateImage({
    required Template template,
    required Uint8List imageBytes,
    required String userId,
    String? sourcePath,
  }) async {
    // Délai réaliste (2–4 s).
    await Future<void>.delayed(
      Duration(milliseconds: 2000 + _rng.nextInt(2000)),
    );
    // Petit taux d'échec simulé pour exercer les états d'erreur.
    if (_rng.nextDouble() < 0.06) {
      throw const AppException('La génération a échoué. Réessaie.');
    }
    final GenerationResult result = GenerationResult(
      id: _newId(),
      templateId: template.id,
      templateTitle: template.title,
      category: template.category,
      outputUrl:
          'morfo://demo/${template.id}/${DateTime.now().millisecondsSinceEpoch}',
      kind: template.kind,
      createdAt: DateTime.now(),
      sourcePath: sourcePath,
    );
    // -1 : crédits gérés localement en mode mock.
    return GenerationOutcome(result, -1);
  }

  @override
  Future<String> submitVideo({
    required Template template,
    required Uint8List imageBytes,
    required String userId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    final String id = _newId();
    _videoJobs[id] = DateTime.now();
    return id;
  }

  @override
  Future<VideoStatus> pollVideo(String requestId) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    final DateTime? started = _videoJobs[requestId];
    if (started == null) return const VideoStatus(VideoPhase.failed);
    if (DateTime.now().difference(started) > const Duration(seconds: 4)) {
      return VideoStatus(
        VideoPhase.completed,
        url: 'morfo://demo/video/$requestId',
      );
    }
    return const VideoStatus(VideoPhase.pending);
  }

  String _newId() =>
      '${DateTime.now().microsecondsSinceEpoch}_${_rng.nextInt(9999)}';
}
