import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  });

  final String id;
  final String title;
  final String price;
  final String subtitle;
  final OfferPeriod period;
  final bool highlighted;
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
          price: '4,99 €',
          subtitle: 'par semaine',
          period: OfferPeriod.weekly,
        ),
        SubscriptionOffer(
          id: 'annual',
          title: 'Annuel',
          price: '29,99 €',
          subtitle: 'soit 0,58 €/semaine',
          period: OfferPeriod.annual,
          highlighted: true,
        ),
      ];

  @override
  Future<List<CreditPack>> creditPacks() async => const <CreditPack>[
        CreditPack(id: 'pack_50', title: '50 crédits', credits: 50, price: '5,99 €'),
        CreditPack(
          id: 'pack_150',
          title: '150 crédits',
          credits: 150,
          price: '12,99 €',
          bestValue: true,
        ),
        CreditPack(id: 'pack_500', title: '500 crédits', credits: 500, price: '34,99 €'),
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

final Provider<PurchasesService> purchasesServiceProvider =
    Provider<PurchasesService>((Ref ref) => DemoPurchasesService());
