import 'package:flutter/services.dart';

/// Retours haptiques — sémantiques et discrets.
///
/// Sans effet sur le web (les appels sont ignorés), donc pas de garde nécessaire.
abstract final class Haptics {
  static void light() => HapticFeedback.lightImpact();
  static void medium() => HapticFeedback.mediumImpact();
  static void heavy() => HapticFeedback.heavyImpact();
  static void selection() => HapticFeedback.selectionClick();

  /// Petite montée « réussite » (reveal du résultat).
  static Future<void> success() async {
    HapticFeedback.mediumImpact();
    await Future<void>.delayed(const Duration(milliseconds: 90));
    HapticFeedback.lightImpact();
  }
}
