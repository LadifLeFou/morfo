// Implémentation RevenueCat des achats (mobile uniquement).
//
// Activée seulement si `REVENUECAT_PUBLIC_SDK_KEY` est renseignée dans `.env` ;
// sinon `purchases_service_io.dart` retombe sur la démo.
//
// ── Pourquoi ce fichier ne dépend d'aucune configuration RevenueCat ──
//
// L'usage canonique passe par des *offerings* et un *entitlement*, tous deux à
// créer à la main dans le tableau de bord. Chaque étape est une occasion de se
// tromper — un package mal nommé, un entitlement oublié — et l'échec est
// silencieux : le paywall affiche « offres indisponibles » sans rien expliquer.
//
// On s'appuie donc d'abord sur ce qui existe **sans configuration** : les
// identifiants produits de l'App Store, connus et figés. Les offerings et
// l'entitlement restent prioritaires s'ils sont configurés — c'est un filet,
// pas un remplacement.

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../core/strings.dart';
import 'purchases_service.dart';

class RevenueCatPurchasesService implements PurchasesService {
  RevenueCatPurchasesService(this._apiKey);

  final String _apiKey;

  /// Entitlement configuré dans RevenueCat, s'il l'a été.
  static const String _entitlementId = 'pro';

  // Identifiants App Store, créés le 22/07/2026. Ils ne changent jamais :
  // Apple interdit de modifier un identifiant produit après création.
  static const String _weeklyId = 'com.morfo.app.weekly';
  static const String _annualId = 'com.morfo.app.annual';
  static const List<String> _abonnements = <String>[_weeklyId, _annualId];
  static const List<String> _packs = <String>[
    'com.morfo.app.pack100',
    'com.morfo.app.pack300',
    'com.morfo.app.pack1000',
  ];

  String? _cachedUid;

  @override
  Future<void> init() async {
    // En release on reste discret ; ailleurs le SDK détaille quels
    // identifiants il demande à Apple et lesquels sont refusés — la seule
    // façon de diagnostiquer un paywall vide.
    await Purchases.setLogLevel(
        kReleaseMode ? LogLevel.warn : LogLevel.debug);
    await Purchases.configure(PurchasesConfiguration(_apiKey));
  }

  @override
  String get appUserId => _cachedUid ?? 'rc_pending';

  @override
  Future<bool> isSubscribed() async {
    try {
      final CustomerInfo info = await Purchases.getCustomerInfo();
      _cachedUid = info.originalAppUserId;

      // L'entitlement fait foi quand il existe.
      if (info.entitlements.active.containsKey(_entitlementId)) return true;

      // Sinon on regarde ce qui est réellement souscrit : un abonnement actif
      // vaut accès, que le tableau de bord soit configuré ou non.
      return info.activeSubscriptions.any(_abonnements.contains);
    } catch (e) {
      debugPrint('RevenueCat isSubscribed: $e');
      return false;
    }
  }

  @override
  Future<List<SubscriptionOffer>> offers() async {
    // 1. Les offerings, s'ils sont configurés.
    try {
      final Offering? current = (await Purchases.getOfferings()).current;
      if (current != null && current.availablePackages.isNotEmpty) {
        return current.availablePackages
            .map((Package p) => _offreDepuis(p.storeProduct,
                annuel: p.packageType == PackageType.annual))
            .toList();
      }
    } catch (e) {
      debugPrint('RevenueCat offerings: $e');
    }

    // 2. Repli : les produits par identifiant, sans configuration requise.
    try {
      final List<StoreProduct> produits =
          await Purchases.getProducts(_abonnements);
      final List<SubscriptionOffer> offres = produits
          .map((StoreProduct p) =>
              _offreDepuis(p, annuel: p.identifier == _annualId))
          .toList();
      // L'hebdomadaire d'abord : c'est le palier d'entrée mis en avant.
      offres.sort((SubscriptionOffer a, SubscriptionOffer b) =>
          a.period == OfferPeriod.weekly ? -1 : 1);
      return offres;
    } catch (e) {
      debugPrint('RevenueCat getProducts abonnements: $e');
      return const <SubscriptionOffer>[];
    }
  }

  SubscriptionOffer _offreDepuis(StoreProduct p, {required bool annuel}) {
    return SubscriptionOffer(
      // On indexe sur l'identifiant App Store : c'est lui qui sert ensuite à
      // retrouver le produit au moment de l'achat.
      id: p.identifier,
      title: annuel ? S.planYearly : S.planWeekly,
      price: p.priceString,
      subtitle: annuel ? S.planYearlySub : S.creditsPerWeek,
      period: annuel ? OfferPeriod.annual : OfferPeriod.weekly,
      highlighted: !annuel,
      trialDays: _joursDEssai(p.introductoryPrice),
    );
  }

  /// Convertit la période d'essai d'introduction en jours.
  int _joursDEssai(IntroductoryPrice? intro) {
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
    try {
      final Offering? credits =
          (await Purchases.getOfferings()).getOffering('credits');
      if (credits != null && credits.availablePackages.isNotEmpty) {
        return credits.availablePackages
            .map((Package p) => _packDepuis(p.storeProduct))
            .toList();
      }
    } catch (e) {
      debugPrint('RevenueCat offering credits: $e');
    }

    try {
      final List<StoreProduct> produits = await Purchases.getProducts(
        _packs,
        productCategory: ProductCategory.nonSubscription,
      );
      final List<CreditPack> packs = produits.map(_packDepuis).toList();
      packs.sort((CreditPack a, CreditPack b) => a.credits.compareTo(b.credits));
      return packs;
    } catch (e) {
      debugPrint('RevenueCat getProducts packs: $e');
      return const <CreditPack>[];
    }
  }

  CreditPack _packDepuis(StoreProduct p) {
    final int credits = _creditsPour(p.identifier);
    return CreditPack(
      id: p.identifier,
      title: S.creditsPack(credits),
      credits: credits,
      price: p.priceString,
    );
  }

  /// Nombre de crédits déduit de l'identifiant produit.
  ///
  /// L'ordre compte : « 1000 » contient « 100 ».
  int _creditsPour(String identifiant) {
    for (final int montant in const <int>[1000, 300, 100]) {
      if (identifiant.contains('$montant')) return montant;
    }
    return 0;
  }

  @override
  Future<PurchaseOutcome> purchaseSubscription(String offerId) =>
      _acheter(offerId, abonnement: true);

  @override
  Future<PurchaseOutcome> purchaseCredits(String packId) =>
      _acheter(packId, abonnement: false);

  /// Achète par identifiant, que RevenueCat ait des offerings ou non.
  Future<PurchaseOutcome> _acheter(String id, {required bool abonnement}) async {
    try {
      // Le package correspondant s'il existe : il porte les offres
      // promotionnelles éventuellement configurées.
      final Package? pkg = await _packagePour(id, abonnement: abonnement);
      if (pkg != null) {
        return _resultat(
          await Purchases.purchase(PurchaseParams.package(pkg)),
          abonnement: abonnement,
        );
      }

      final List<StoreProduct> produits = await Purchases.getProducts(
        <String>[id],
        productCategory: abonnement
            ? ProductCategory.subscription
            : ProductCategory.nonSubscription,
      );
      if (produits.isEmpty) {
        debugPrint('RevenueCat: produit $id introuvable');
        return PurchaseOutcome.failed;
      }
      return _resultat(
        await Purchases.purchase(PurchaseParams.storeProduct(produits.first)),
        abonnement: abonnement,
      );
    } on PlatformException catch (e) {
      return _issuePour(e);
    } catch (e) {
      debugPrint('RevenueCat achat $id: $e');
      return PurchaseOutcome.failed;
    }
  }

  Future<Package?> _packagePour(String id, {required bool abonnement}) async {
    try {
      final Offerings offerings = await Purchases.getOfferings();
      final Offering? o =
          abonnement ? offerings.current : offerings.getOffering('credits');
      return o?.availablePackages
          .where((Package p) =>
              p.identifier == id || p.storeProduct.identifier == id)
          .firstOrNull;
    } catch (_) {
      return null;
    }
  }

  PurchaseOutcome _resultat(PurchaseResult r, {required bool abonnement}) {
    if (!abonnement) return PurchaseOutcome.success;
    final CustomerInfo info = r.customerInfo;
    final bool actif = info.entitlements.active.containsKey(_entitlementId) ||
        info.activeSubscriptions.any(_abonnements.contains);
    return actif ? PurchaseOutcome.success : PurchaseOutcome.failed;
  }

  /// Fermer la feuille de paiement n'est pas une panne : on le remonte à part
  /// pour ne pas afficher d'erreur à un utilisateur qui a simplement renoncé.
  PurchaseOutcome _issuePour(PlatformException e) =>
      PurchasesErrorHelper.getErrorCode(e) ==
              PurchasesErrorCode.purchaseCancelledError
          ? PurchaseOutcome.cancelled
          : PurchaseOutcome.failed;

  @override
  Future<bool> restore() async {
    try {
      final CustomerInfo info = await Purchases.restorePurchases();
      _cachedUid = info.originalAppUserId;
      return info.entitlements.active.containsKey(_entitlementId) ||
          info.activeSubscriptions.any(_abonnements.contains);
    } catch (e) {
      debugPrint('RevenueCat restore: $e');
      return false;
    }
  }
}
