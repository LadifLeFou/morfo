import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/env.dart';
import 'paywall_service_factory.dart';

/// Contrat paywall distant — implémenté par Superwall sur mobile.
abstract interface class PaywallService {
  /// Tente de présenter un paywall distant (A/B testé côté Superwall).
  ///
  /// Retourne true si pris en charge à distance ; false → l'app affiche son
  /// paywall natif de secours (toujours présent et magnifique).
  Future<bool> presentRemotePaywall({String placement});
}

/// Stub web/dev : aucun paywall distant → l'app utilise le paywall natif.
class StubPaywallService implements PaywallService {
  const StubPaywallService();

  @override
  Future<bool> presentRemotePaywall({String placement = 'default'}) async =>
      false;
}

/// Sélectionne Superwall (mobile) ou le stub (web/desktop) via la factory
/// à imports conditionnels. La clé publique vient de `.env`.
final Provider<PaywallService> paywallServiceProvider =
    Provider<PaywallService>(
  (Ref ref) => createPaywallService(Env.superwallKey),
);
