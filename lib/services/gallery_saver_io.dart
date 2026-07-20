import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gal/gal.dart';

import 'save_outcome.dart';

/// Album dédié créé dans la photothèque.
const String _album = 'Morfo';

/// Enregistre le média dans la photothèque (iOS / Android).
///
/// [url] accepte une URL réseau (`http(s)://`) — le média est alors téléchargé
/// avant d'être écrit — ou un chemin de fichier local (`/…` ou `file://…`).
Future<SaveOutcome> saveToGallery({
  required String url,
  required bool isVideo,
}) async {
  try {
    // Écrire dans un album nommé exige l'accès **complet** sur iOS. Si
    // l'utilisateur n'a accordé que « Ajouter des photos uniquement », on
    // enregistre quand même — à la racine de la photothèque plutôt que dans
    // l'album Morfo. Refuser ici serait un faux échec.
    final bool canUseAlbum = await Gal.hasAccess(toAlbum: true) ||
        await Gal.requestAccess(toAlbum: true);

    if (!canUseAlbum &&
        !await Gal.hasAccess() &&
        !await Gal.requestAccess()) {
      return SaveOutcome.permissionDenied;
    }
    final String? album = canUseAlbum ? _album : null;

    if (url.startsWith('http')) {
      final Response<List<int>> res = await Dio().get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      final List<int>? data = res.data;
      if (data == null || data.isEmpty) return SaveOutcome.failed;

      if (isVideo) {
        // gal n'accepte la vidéo que depuis un fichier : on passe par un
        // temporaire, supprimé une fois la copie faite par la photothèque.
        final File tmp = await File(
          '${Directory.systemTemp.path}/morfo_'
          '${DateTime.now().millisecondsSinceEpoch}.mp4',
        ).writeAsBytes(data);
        try {
          await Gal.putVideo(tmp.path, album: album);
        } finally {
          await tmp.delete().catchError((_) => tmp);
        }
      } else {
        await Gal.putImageBytes(Uint8List.fromList(data), album: album);
      }
      return SaveOutcome.success;
    }

    final String path =
        url.startsWith('file://') ? Uri.parse(url).toFilePath() : url;
    if (!await File(path).exists()) return SaveOutcome.failed;

    if (isVideo) {
      await Gal.putVideo(path, album: album);
    } else {
      await Gal.putImage(path, album: album);
    }
    return SaveOutcome.success;
  } on GalException catch (e) {
    return e.type == GalExceptionType.accessDenied
        ? SaveOutcome.permissionDenied
        : SaveOutcome.failed;
  } catch (_) {
    return SaveOutcome.failed;
  }
}
