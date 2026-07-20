// Implémentation RevenueCat des achats (mobile uniquement).
//
// Activée seulement si `REVENUECAT_PUBLIC_SDK_KEY` est renseignée dans
// `.env` ; sinon `purchases_service_io.dart` retombe sur la démo.
import 'package:purchases_flutter/purchases_flutter.dart';

import '../core/strings.dart';
import 'purchases_service.dart';

/// Implémentation RevenueCat (mobile). Mappe les offerings RevenueCat vers les
/// modèles internes [SubscriptionOffer] / [CreditPack].
class RevenueCatPurchasesService implements PurchasesService {
  RevenueCatPurchasesService(this._apiKey);

  final String _apiKey;

  /// Identifiant de l'entitlement « pro » configuré dans RevenueCat.
  static const String _entitlementId = 'pro';

  @override
  Future<void> init() async {
    await Purchases.setLogLevel(LogLevel.warn);
    await Purchases.configure(PurchasesConfiguration(_apiKey));
  }

  @override
  String get appUserId {
    // RevenueCat gère l'anonymous id ; récupéré de façon asynchrone ailleurs.
    // Pour un usage synchrone immédiat, mémorise-le après init().
    return _cachedUid ?? 'rc_pending';
  }

  String? _cachedUid;

  @override
  Future<bool> isSubscribed() async {
    final CustomerInfo info = await Purchases.getCustomerInfo();
    _cachedUid = info.originalAppUserId;
    return info.entitlements.active.containsKey(_entitlementId);
  }

  @override
  Future<List<SubscriptionOffer>> offers() async {
    final Offerings offerings = await Purchases.getOfferings();
    final Offering? current = offerings.current;
    if (current == null) return const <SubscriptionOffer>[];

    return current.availablePackages.map((Package p) {
      final StoreProduct sp = p.storeProduct;
      final bool annual = p.packageType == PackageType.annual;
      return SubscriptionOffer(
        id: p.identifier,
        title: annual ? S.planYearly : S.planWeekly,
        price: sp.priceString,
        subtitle: sp.description,
        period: annual ? OfferPeriod.annual : OfferPeriod.weekly,
        highlighted: annual,
        // Essai gratuit = offre d'introduction configurée dans App Store Connect.
        trialDays: _trialDays(sp.introductoryPrice),
      );
    }).toList();
  }

  /// Convertit la période d'essai d'introduction en jours (approx.).
  int _trialDays(IntroductoryPrice? intro) {
    if (intro == null || intro.price != 0) return 0;
    final int n = intro.periodNumberOfUnits;
    return switch (intro.periodUnit) {
      PeriodUnit.day => n,
      PeriodUnit.week => n * 7,
      PeriodUnit.month => n * 30,
      PeriodUnit.year => n * 365,
      _ => n,
    };
  }

  @override
  Future<List<CreditPack>> creditPacks() async {
    // Configure une offering « credits » dédiée dans RevenueCat.
    final Offerings offerings = await Purchases.getOfferings();
    final Offering? credits = offerings.getOffering('credits');
    if (credits == null) return const <CreditPack>[];

    return credits.availablePackages.map((Package p) {
      final StoreProduct sp = p.storeProduct;
      return CreditPack(
        id: p.identifier,
        title: sp.title,
        credits: _creditsForProduct(p.identifier),
        price: sp.priceString,
      );
    }).toList();
  }

  /// Mappe un identifiant de produit → nombre de crédits (à aligner sur ta
  /// config App Store Connect).
  int _creditsForProduct(String id) => switch (id) {
        'pack_100' => 100,
        'pack_300' => 300,
        'pack_1000' => 1000,
        _ => 0,
      };

  @override
  Future<bool> purchaseSubscription(String offerId) async {
    try {
      final Offerings offerings = await Purchases.getOfferings();
      final Package? pkg = offerings.current?.availablePackages
          .where((Package p) => p.identifier == offerId)
          .firstOrNull;
      if (pkg == null) return false;
      final PurchaseResult result =
          await Purchases.purchase(PurchaseParams.package(pkg));
      return result.customerInfo.entitlements.active
          .containsKey(_entitlementId);
    } on PurchasesErrorCode {
      return false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> purchaseCredits(String packId) async {
    try {
      final Offerings offerings = await Purchases.getOfferings();
      final Package? pkg = offerings
          .getOffering('credits')
          ?.availablePackages
          .where((Package p) => p.identifier == packId)
          .firstOrNull;
      if (pkg == null) return false;
      await Purchases.purchase(PurchaseParams.package(pkg));
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> restore() async {
    try {
      final CustomerInfo info = await Purchases.restorePurchases();
      return info.entitlements.active.containsKey(_entitlementId);
    } catch (_) {
      return false;
    }
  }
}
