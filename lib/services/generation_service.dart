import 'dart:typed_data';

import '../core/models/generation_result.dart';
import '../core/models/template.dart';

/// Phase d'une génération vidéo (submit + polling).
enum VideoPhase { pending, completed, failed }

/// Statut renvoyé par le polling vidéo (contrat §5 : GET /video-status).
class VideoStatus {
  const VideoStatus(this.phase, {this.url});

  final VideoPhase phase;
  final String? url;

  bool get isDone => phase != VideoPhase.pending;

  factory VideoStatus.fromJson(Map<String, dynamic> j) => VideoStatus(
        switch (j['status']) {
          'completed' => VideoPhase.completed,
          'failed' => VideoPhase.failed,
          _ => VideoPhase.pending,
        },
        url: j['url'] as String?,
      );
}

/// Issue d'une génération image : résultat + crédits restants.
///
/// [creditsLeft] == -1 signifie « inconnu » (mock) → géré localement.
class GenerationOutcome {
  const GenerationOutcome(this.result, this.creditsLeft);

  final GenerationResult result;
  final int creditsLeft;
}

/// Contrat du service de génération — implémenté par le mock et par l'API réelle.
///
/// L'app n'envoie que : identifiant utilisateur, id de template, image.
/// Aucune clé de modèle IA ne transite par l'app.
abstract interface class GenerationService {
  Future<List<Template>> fetchTemplates();

  Future<GenerationOutcome> generateImage({
    required Template template,
    required Uint8List imageBytes,
    required String userId,
    String? sourcePath,
  });

  /// Vidéo : soumet le job et renvoie un `requestId` à poller.
  Future<String> submitVideo({
    required Template template,
    required Uint8List imageBytes,
    required String userId,
  });

  Future<VideoStatus> pollVideo(String requestId);
}
