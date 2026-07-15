/// Catégories éditoriales de templates.
enum MorfoCategory {
  epique('Épique'),
  retro('Rétro'),
  fun('Fun'),
  glow('Glow'),
  cinema('Cinéma'),
  video('Vidéo');

  const MorfoCategory(this.label);

  /// Libellé affiché (FR).
  final String label;

  /// Parse depuis le libellé backend (tolérant à la casse/accents manquants).
  static MorfoCategory fromLabel(String raw) {
    final String needle = raw.trim().toLowerCase();
    for (final MorfoCategory c in values) {
      if (c.label.toLowerCase() == needle || c.name == needle) return c;
    }
    return MorfoCategory.fun;
  }
}
