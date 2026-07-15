/// Erreur applicative présentable à l'utilisateur.
///
/// Toujours dans la voix de l'app (« La génération a échoué. Réessaie. »),
/// jamais de stacktrace ni de « null » visibles.
class AppException implements Exception {
  const AppException(
    this.message, {
    this.insufficientCredits = false,
    this.cause,
  });

  /// Message court, en français, prêt à afficher.
  final String message;

  /// true si l'échec vient d'un manque de crédits (→ ouvrir crédits/paywall).
  final bool insufficientCredits;

  /// Cause technique (loggée, jamais montrée).
  final Object? cause;

  @override
  String toString() => 'AppException($message)';
}
