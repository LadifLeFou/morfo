import 'result_cache_stub.dart'
    if (dart.library.io) 'result_cache_io.dart' as impl;

/// Télécharge et stocke localement l'image d'un résultat.
///
/// Renvoie le chemin local, ou null (web, échec, non-http) : l'appelant
/// conserve alors l'URL distante.
Future<String?> cacheResultImage(String url, String id) =>
    impl.cacheResultImage(url, id);

/// Supprime les fichiers cachés absents de [keepIds].
Future<void> pruneCachedResults(Iterable<String> keepIds) =>
    impl.pruneCachedResults(keepIds);
