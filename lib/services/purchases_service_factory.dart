import 'purchases_service.dart';
// Import conditionnel : web/desktop → stub démo ; mobile (io) → branchement SDK.
import 'purchases_service_stub.dart'
    if (dart.library.io) 'purchases_service_io.dart' as impl;

/// Fabrique l'implémentation d'achats adaptée à la plateforme.
///
/// - **Web / desktop** → [DemoPurchasesService] (aucun SDK natif, build web OK).
/// - **Mobile (iOS/Android)** → point de branchement RevenueCat. Par défaut la
///   démo est renvoyée tant que le SDK `purchases_flutter` n'est pas ajouté ;
///   voir `integration/INTEGRATION.md` pour l'activer en une ligne.
PurchasesService createPurchasesService(String revenueCatApiKey) =>
    impl.createPurchasesService(revenueCatApiKey);
