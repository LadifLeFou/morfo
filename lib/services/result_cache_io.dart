import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

/// Dossier persistant des créations, sous le support de l'app.
Future<Directory> _dir() async {
  final Directory base = await getApplicationSupportDirectory();
  final Directory dir = Directory('${base.path}/morfo_results');
  if (!await dir.exists()) await dir.create(recursive: true);
  return dir;
}

/// Télécharge le résultat et le stocke localement. Renvoie le chemin, ou null
/// en cas d'échec (l'appelant garde alors l'URL distante).
///
/// Ce cache est ce qui rend l'historique durable : l'URL Replicate distante
/// expire au bout de ~1 h, la copie locale reste.
Future<String?> cacheResultImage(String url, String id) async {
  // Rien à télécharger pour une démo ou un fichier déjà local.
  if (!url.startsWith('http')) return null;
  try {
    final Response<List<int>> res = await Dio().get<List<int>>(
      url,
      options: Options(
        responseType: ResponseType.bytes,
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
    final List<int>? data = res.data;
    if (data == null || data.isEmpty) return null;

    final File file = File('${(await _dir()).path}/$id.jpg');
    await file.writeAsBytes(data);
    return file.path;
  } catch (_) {
    return null;
  }
}

/// Supprime les fichiers cachés dont l'id n'est plus dans l'historique.
///
/// Évite que le dossier grossisse indéfiniment quand l'utilisateur efface des
/// créations ou que l'historique est plafonné.
Future<void> pruneCachedResults(Iterable<String> keepIds) async {
  try {
    final Set<String> keep = keepIds.toSet();
    final Directory dir = await _dir();
    if (!await dir.exists()) return;
    await for (final FileSystemEntity e in dir.list()) {
      if (e is! File) continue;
      final String name = e.uri.pathSegments.last;
      final String id = name.endsWith('.jpg')
          ? name.substring(0, name.length - 4)
          : name;
      if (!keep.contains(id)) await e.delete().catchError((_) => e);
    }
  } catch (_) {
    // Best-effort : un échec de purge n'est pas critique.
  }
}
