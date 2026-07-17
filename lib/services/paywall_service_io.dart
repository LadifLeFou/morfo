import 'paywall_service.dart';

/// Mobile (iOS / Android) — point de branchement **Superwall**.
///
/// Tant que le SDK natif n'est pas ajouté, on renvoie le stub (l'app affiche
/// son paywall natif). Pour activer Superwall (voir `integration/INTEGRATION.md`) :
///
/// 1. `flutter pub add superwallkit_flutter`
/// 2. Copier `integration/paywall_service_superwall.dart.example`
///    → `lib/services/paywall_service_superwall.dart`
/// 3. Remplacer le corps ci-dessous par :
///    ```dart
///    if (superwallApiKey.isEmpty) return const StubPaywallService();
///    return SuperwallPaywallService(superwallApiKey);
///    ```
PaywallService createPaywallService(String superwallApiKey) {
  return const StubPaywallService();
}
