/// Stub web : pas de système de fichiers, on garde l'URL distante.
Future<String?> cacheResultImage(String url, String id) async => null;

/// Purge web : rien à faire.
Future<void> pruneCachedResults(Iterable<String> keepIds) async {}
