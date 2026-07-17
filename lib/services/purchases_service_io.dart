import 'purchases_service.dart';

/// Mobile (iOS / Android) — point de branchement **RevenueCat**.
///
/// Tant que le SDK natif n'est pas ajouté, on renvoie la démo pour ne casser
/// aucun build. Pour activer RevenueCat (voir `integration/INTEGRATION.md`) :
///
/// 1. `flutter pub add purchases_flutter`
/// 2. Copier `integration/purchases_service_revenuecat.dart.example`
///    → `lib/services/purchases_service_revenuecat.dart`
/// 3. Remplacer le corps ci-dessous par :
///    ```dart
///    if (revenueCatApiKey.isEmpty) return DemoPurchasesService();
///    return RevenueCatPurchasesService(revenueCatApiKey);
///    ```
PurchasesService createPurchasesService(String revenueCatApiKey) {
  return DemoPurchasesService();
}
