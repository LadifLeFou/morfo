/// Catégories du catalogue — trends actuels (fini les catégories génériques).
enum MorfoCategory {
  tendance('Tendance'),
  aesthetic('Aesthetic'),
  fun('Fun'),
  jeux('Jeux'),
  cinema('Cinéma');

  const MorfoCategory(this.label);

  /// Libellé affiché.
  final String label;

  /// Parse depuis le libellé backend (tolérant à la casse).
  static MorfoCategory fromLabel(String raw) {
    final String needle = raw.trim().toLowerCase();
    for (final MorfoCategory c in values) {
      if (c.label.toLowerCase() == needle || c.name == needle) return c;
    }
    return MorfoCategory.tendance;
  }
}
