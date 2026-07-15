import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/generation_result.dart';

/// Persistance locale (flags + crédits + historique).
///
/// Basée sur shared_preferences pour une compatibilité web irréprochable.
/// (Migrable vers Hive pour le mobile — voir README.)
class Prefs {
  Prefs(this._sp);

  final SharedPreferences _sp;

  static const String _kOnboarded = 'morfo_onboarded';
  static const String _kCredits = 'morfo_credits';
  static const String _kHistory = 'morfo_history';

  bool get onboarded => _sp.getBool(_kOnboarded) ?? false;
  Future<void> setOnboarded(bool value) => _sp.setBool(_kOnboarded, value);

  int? get credits => _sp.getInt(_kCredits);
  Future<void> setCredits(int value) => _sp.setInt(_kCredits, value);

  List<GenerationResult> get history {
    final String? raw = _sp.getString(_kHistory);
    if (raw == null || raw.isEmpty) return <GenerationResult>[];
    try {
      final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((dynamic e) =>
              GenerationResult.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return <GenerationResult>[];
    }
  }

  Future<void> setHistory(List<GenerationResult> items) => _sp.setString(
        _kHistory,
        jsonEncode(items.map((GenerationResult e) => e.toJson()).toList()),
      );
}

/// Surchargé dans le bootstrap avec l'instance réelle de [Prefs].
final Provider<Prefs> prefsProvider = Provider<Prefs>(
  (Ref ref) => throw UnimplementedError('prefsProvider doit être surchargé'),
);
