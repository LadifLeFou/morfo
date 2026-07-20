import 'gallery_saver_stub.dart'
    if (dart.library.io) 'gallery_saver_io.dart' as impl;
import 'save_outcome.dart';

export 'save_outcome.dart';

/// Enregistre un média dans la photothèque de l'appareil.
///
/// Sur mobile, délègue à `gal` ; sur web, renvoie [SaveOutcome.unsupported].
Future<SaveOutcome> saveToGallery({
  required String url,
  required bool isVideo,
}) =>
    impl.saveToGallery(url: url, isVideo: isVideo);
