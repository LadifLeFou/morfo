/// Issue d'une tentative d'enregistrement dans la photothèque.
///
/// Type partagé entre la façade et les deux implémentations (io / web) pour
/// éviter tout import circulaire.
enum SaveOutcome {
  /// Le média est bien dans la photothèque.
  success,

  /// L'utilisateur a refusé l'accès à la photothèque.
  permissionDenied,

  /// Plateforme sans photothèque (web) — l'appelant propose le partage.
  unsupported,

  /// Téléchargement, écriture ou format en échec.
  failed,
}
