import 'package:flutter/widgets.dart';

import 'morfo_colors.dart';

/// Typographie Morfo — pairing caractériel.
///
/// - Display / titres : **Clash Display** (Fontshare).
/// - UI / corps : **Satoshi** (Fontshare).
/// - Compteurs de crédits : chiffres tabulaires.
abstract final class MorfoType {
  static const String displayFamily = 'ClashDisplay';
  static const String bodyFamily = 'Satoshi';

  static const TextStyle displayLarge = TextStyle(
    fontFamily: displayFamily,
    fontWeight: FontWeight.w600,
    fontSize: 40,
    height: 1.04,
    letterSpacing: -1.0,
    color: MorfoColors.ink,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: displayFamily,
    fontWeight: FontWeight.w600,
    fontSize: 34,
    height: 1.06,
    letterSpacing: -0.8,
    color: MorfoColors.ink,
  );

  static const TextStyle titleLarge = TextStyle(
    fontFamily: displayFamily,
    fontWeight: FontWeight.w500,
    fontSize: 26,
    height: 1.1,
    letterSpacing: -0.4,
    color: MorfoColors.ink,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: displayFamily,
    fontWeight: FontWeight.w500,
    fontSize: 22,
    height: 1.15,
    letterSpacing: -0.2,
    color: MorfoColors.ink,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: bodyFamily,
    fontWeight: FontWeight.w600,
    fontSize: 18,
    height: 1.25,
    color: MorfoColors.ink,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: bodyFamily,
    fontWeight: FontWeight.w400,
    fontSize: 16,
    height: 1.45,
    color: MorfoColors.ink,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: bodyFamily,
    fontWeight: FontWeight.w400,
    fontSize: 15,
    height: 1.45,
    color: MorfoColors.muted,
  );

  static const TextStyle label = TextStyle(
    fontFamily: bodyFamily,
    fontWeight: FontWeight.w500,
    fontSize: 14,
    height: 1.2,
    color: MorfoColors.ink,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: bodyFamily,
    fontWeight: FontWeight.w400,
    fontSize: 13,
    height: 1.3,
    color: MorfoColors.muted,
  );

  /// Eyebrow — petit label espacé (nom de template, sur-titres).
  static const TextStyle eyebrow = TextStyle(
    fontFamily: bodyFamily,
    fontWeight: FontWeight.w600,
    fontSize: 12,
    height: 1.2,
    letterSpacing: 1.6,
    color: MorfoColors.muted,
  );

  /// Compteur de crédits — chiffres tabulaires pour éviter le « saut ».
  static const TextStyle credits = TextStyle(
    fontFamily: bodyFamily,
    fontWeight: FontWeight.w700,
    fontSize: 18,
    height: 1.0,
    color: MorfoColors.ink,
    fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
  );
}
