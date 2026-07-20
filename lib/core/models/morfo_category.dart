import '../strings.dart';

/// Catégories du catalogue — trends actuels (fini les catégories génériques).
enum MorfoCategory {
  tendance('Tendance'),
  aesthetic('Aesthetic'),
  fun('Fun'),
  jeux('Jeux'),
  cinema('Cinéma');

  const MorfoCategory(this.key);

  /// Clé stable telle qu'échangée avec le backend — **ne jamais traduire**,
  /// c'est elle qui sert à l'appairage dans [fromLabel].
  final String key;

  /// Libellé affiché, suit la langue de l'interface.
  String get label => switch (this) {
        MorfoCategory.tendance => S.catTrending,
        MorfoCategory.aesthetic => S.catAesthetic,
        MorfoCategory.fun => S.catFun,
        MorfoCategory.jeux => S.catGames,
        MorfoCategory.cinema => S.catCinema,
      };

  /// Parse depuis le libellé backend (tolérant à la casse).
  static MorfoCategory fromLabel(String raw) {
    final String needle = raw.trim().toLowerCase();
    for (final MorfoCategory c in values) {
      if (c.key.toLowerCase() == needle || c.name == needle) return c;
    }
    return MorfoCategory.tendance;
  }
}
