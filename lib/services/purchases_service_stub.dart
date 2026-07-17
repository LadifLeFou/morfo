import 'purchases_service.dart';

/// Web / desktop : pas de SDK d'achat natif → service de démo.
PurchasesService createPurchasesService(String revenueCatApiKey) =>
    DemoPurchasesService();
