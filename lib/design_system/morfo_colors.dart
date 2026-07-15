import 'package:flutter/material.dart';

/// Palette Morfo — dark-first, spectre holographique utilisé avec parcimonie.
///
/// Le gradient « holo foil » ne sert QUE : le CTA primaire, l'anneau de
/// génération et la carte-résultat. Partout ailleurs : noir profond, verre
/// subtil, texte contrasté, beaucoup de vide.
abstract final class MorfoColors {
  // — Fonds —
  /// Fond quasi-noir, légèrement indigo.
  static const Color voidColor = Color(0xFF07060D);

  /// Surfaces surélevées (verre).
  static const Color surface = Color(0xFF121020);

  /// Cartes / sheets.
  static const Color surface2 = Color(0xFF1B1730);

  // — Texte —
  /// Texte principal (blanc légèrement violet).
  static const Color ink = Color(0xFFF5F3FF);

  /// Texte secondaire (lavande-gris).
  static const Color muted = Color(0xFF8B87A8);

  // — Bordures —
  /// Bordures hairline — rgba(255,255,255,0.08).
  static const Color stroke = Color(0x14FFFFFF);

  // — Accents holographiques —
  static const Color holoCyan = Color(0xFF6EE7F9);
  static const Color holoViolet = Color(0xFFA78BFA);
  static const Color holoPink = Color(0xFFF0ABFC);
  static const Color holoWarm = Color(0xFFFDBA74);

  /// Couleur d'erreur, alignée sur la palette (corail plutôt que rouge cru).
  static const Color danger = Color(0xFFFF7A8A);

  /// Les 4 teintes du gradient signature, dans l'ordre.
  static const List<Color> holo = <Color>[
    holoCyan,
    holoViolet,
    holoPink,
    holoWarm,
  ];

  /// Gradient signature « holo foil ».
  static const LinearGradient holoGradient = LinearGradient(
    colors: holo,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Variante balayage — pour l'anneau de progression (boucle fermée).
  static const SweepGradient holoSweep = SweepGradient(
    colors: <Color>[holoCyan, holoViolet, holoPink, holoWarm, holoCyan],
  );

  /// Voile sombre pour poser du texte par-dessus une image.
  static const LinearGradient scrim = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[Color(0x00000000), Color(0xCC07060D)],
    stops: <double>[0.35, 1.0],
  );
}
