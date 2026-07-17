import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/env.dart';
import 'purchases_service_factory.dart';

/// Périodicité d'un abonnement.
enum OfferPeriod { weekly, annual }

/// Offre d'abonnement (mappée depuis les offerings RevenueCat côté mobile).
class SubscriptionOffer {
  const SubscriptionOffer({
    required this.id,
    required this.title,
    required this.price,
    required this.period,
    this.subtitle = '',
    this.highlighted = false,
    this.trialDays = 0,
  });

  final String id;
  final String title;
  final String price;
  final String subtitle;
  final OfferPeriod period;
  final bool highlighted;

  /// Nombre de jours d'essai gratuit (0 = aucun). Mappé depuis l'offre
  /// d'introduction RevenueCat / App Store Connect.
  final int trialDays;

  bool get hasTrial => trialDays > 0;
}

/// Pack de crédits (offerings RevenueCat).
class CreditPack {
  const CreditPack({
    required this.id,
    required this.title,
    required this.credits,
    required this.price,
    this.bestValue = false,
  });

  final String id;
  final String title;
  final int credits;
  final String price;
  final bool bestValue;
}

/// Contrat achats/abonnements — implémenté par RevenueCat sur mobile,
/// par [DemoPurchasesService] sur web/dev.
abstract interface class PurchasesService {
  Future<void> init();
  String get appUserId;
  Future<bool> isSubscribed();
  Future<List<SubscriptionOffer>> offers();
  Future<List<CreditPack>> creditPacks();
  Future<bool> purchaseSubscription(String offerId);
  Future<bool> purchaseCredits(String packId);
  Future<bool> restore();
}

/// Implémentation de démo : simule l'achat/restauration sans SDK natif.
///
/// Voir README §Monétisation pour brancher RevenueCat (SDK iOS/Android).
class DemoPurchasesService implements PurchasesService {
  bool _subscribed = false;
  final String _uid = 'demo_${Random().nextInt(1 << 30)}';

  @override
  String get appUserId => _uid;

  @override
  Future<void> init() async {}

  @override
  Future<bool> isSubscribed() async => _subscribed;

  @override
  Future<List<SubscriptionOffer>> offers() async => const <SubscriptionOffer>[
        SubscriptionOffer(
          id: 'weekly',
          title: 'Hebdomadaire',
          price: '3,99 €',
          subtitle: '650 crédits / semaine',
          period: OfferPeriod.weekly,
          // Essai gratuit = principal levier de conversion.
          highlighted: true,
          trialDays: 3,
        ),
        SubscriptionOffer(
          id: 'annual',
          title: 'Annuel',
          price: '99,99 €',
          subtitle: 'soit 1,92 €/semaine — économise 52 %',
          period: OfferPeriod.annual,
          trialDays: 3,
        ),
      ];

  @override
  Future<List<CreditPack>> creditPacks() async => const <CreditPack>[
        CreditPack(
            id: 'pack_100', title: '100 crédits', credits: 100, price: '2,99 €'),
        CreditPack(
          id: 'pack_300',
          title: '300 crédits',
          credits: 300,
          price: '6,99 €',
          bestValue: true,
        ),
        CreditPack(
            id: 'pack_1000',
            title: '1000 crédits',
            credits: 1000,
            price: '19,99 €'),
      ];

  @override
  Future<bool> purchaseSubscription(String offerId) async {
    await _wait();
    _subscribed = true;
    return true;
  }

  @override
  Future<bool> purchaseCredits(String packId) async {
    await _wait();
    return true;
  }

  @override
  Future<bool> restore() async {
    await _wait();
    return _subscribed;
  }

  Future<void> _wait() =>
      Future<void>.delayed(const Duration(milliseconds: 900));
}

/// Sélectionne RevenueCat (mobile) ou la démo (web/desktop) via la factory
/// à imports conditionnels. La clé publique vient de `.env`.
final Provider<PurchasesService> purchasesServiceProvider =
    Provider<PurchasesService>(
  (Ref ref) => createPurchasesService(Env.revenueCatKey),
);
