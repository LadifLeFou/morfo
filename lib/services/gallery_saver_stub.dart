import 'save_outcome.dart';

/// Stub web : pas de photothèque dans le navigateur.
///
/// L'appelant retombe sur le partage / téléchargement natif.
Future<SaveOutcome> saveToGallery({
  required String url,
  required bool isVideo,
}) async =>
    SaveOutcome.unsupported;
