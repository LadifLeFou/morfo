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
    // `toAlbum: true` : sur iOS, écrire dans un album nommé demande l'accès
    // complet, pas seulement l'ajout.
    if (!await Gal.hasAccess(toAlbum: true) &&
        !await Gal.requestAccess(toAlbum: true)) {
      return SaveOutcome.permissionDenied;
    }

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
          await Gal.putVideo(tmp.path, album: _album);
        } finally {
          await tmp.delete().catchError((_) => tmp);
        }
      } else {
        await Gal.putImageBytes(Uint8List.fromList(data), album: _album);
      }
      return SaveOutcome.success;
    }

    final String path =
        url.startsWith('file://') ? Uri.parse(url).toFilePath() : url;
    if (!await File(path).exists()) return SaveOutcome.failed;

    if (isVideo) {
      await Gal.putVideo(path, album: _album);
    } else {
      await Gal.putImage(path, album: _album);
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
