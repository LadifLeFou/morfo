import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Accès typé et défensif à la configuration `.env`.
///
/// Aucune clé secrète de modèle IA ici — seulement l'URL backend et des clés
/// publiques. La logique sensible (prompts, crédits, entitlements) vit côté
/// backend (voir contrat §5).
abstract final class Env {
  static String? _get(String key) =>
      dotenv.isInitialized ? dotenv.maybeGet(key) : null;

  static String get apiUrl => _get('MORFO_API_URL') ?? '';

  static String get supabaseAnonKey => _get('SUPABASE_ANON_KEY') ?? '';

  /// true (défaut) → service mock, l'app tourne sans backend.
  static bool get useMock => (_get('MORFO_USE_MOCK') ?? 'true').toLowerCase() != 'false';

  static String get revenueCatKey => _get('REVENUECAT_PUBLIC_SDK_KEY') ?? '';

  static String get superwallKey => _get('SUPERWALL_API_KEY') ?? '';
}
