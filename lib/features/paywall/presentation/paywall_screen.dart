import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_state.dart';
import '../../../design_system/design_system.dart';
import '../../../services/purchases_service.dart';
import '../../generation/generate_args.dart';
import '../../notifications/conversion_notifications.dart';

final FutureProvider<List<SubscriptionOffer>> _offersProvider =
    FutureProvider<List<SubscriptionOffer>>(
  (Ref ref) => ref.read(purchasesServiceProvider).offers(),
);

const List<String> _benefits = <String>[
  'Générations illimitées',
  'Tous les styles, sans filigrane',
  'De nouveaux styles chaque semaine',
  'Rendus en haute résolution',
];

/// Paywall natif de secours — Superwall prioritaire côté mobile (voir README).
class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key, this.resumeArgs});

  /// Si l'utilisateur arrive ici depuis une génération « teasée », on reprend
  /// cette génération dès l'abonnement souscrit.
  final GenerateArgs? resumeArgs;

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  String? _selected;
  bool _busy = false;

  Future<void> _subscribe(List<SubscriptionOffer> offers) async {
    final String id = _selected ??
        offers
            .firstWhere((SubscriptionOffer o) => o.highlighted,
                orElse: () => offers.first)
            .id;
    setState(() => _busy = true);
    final bool ok =
        await ref.read(purchasesServiceProvider).purchaseSubscription(id);
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) {
      ref.read(subscriptionProvider.notifier).setSubscribed(true);
      _onUnlocked();
    }
  }

  /// Après déblocage : reprend la génération en attente, sinon va au home.
  void _onUnlocked() {
    // Converti → on annule les relances de reconquête programmées.
    ref.read(conversionNotificationsProvider).onConverted();
    final GenerateArgs? resume = widget.resumeArgs;
    if (resume != null) {
      context.pushReplacement('/generate', extra: resume);
    } else {
      context.go('/home');
    }
  }

  Future<void> _restore() async {
    final bool ok = await ref.read(purchasesServiceProvider).restore();
    if (!mounted) return;
    if (ok) {
      ref.read(subscriptionProvider.notifier).setSubscribed(true);
      _onUnlocked();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucun achat à restaurer.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<SubscriptionOffer>> offers =
        ref.watch(_offersProvider);

    return MorfoScaffold(
      body: Stack(
        children: <Widget>[
          ListView(
            padding: const EdgeInsets.fromLTRB(Gap.xl, Gap.sm, Gap.xl, Gap.xl),
            children: <Widget>[
              const SizedBox(height: 40),
              const AspectRatio(
                aspectRatio: 5 / 4,
                child: HoloCard(
                  eyebrow: 'Portrait vivant',
                  title: 'Passe en illimité',
                  child: StylePreview(
                    beforeAsset: 'assets/images/preview_renaissance_before.jpg',
                    afterAsset: 'assets/images/preview_renaissance_after.jpg',
                    borderRadius: BorderRadius.zero,
                  ),
                ),
              ),
              Gap.h24,
              Text('Débloque tout Morfo', style: MorfoType.displayMedium),
              Gap.h16,
              for (final String b in _benefits) _BenefitRow(text: b),
              Gap.h24,
              offers.when(
                data: (List<SubscriptionOffer> list) => Column(
                  children: <Widget>[
                    for (final SubscriptionOffer o in list)
                      Padding(
                        padding: const EdgeInsets.only(bottom: Gap.md),
                        child: _OfferCard(
                          offer: o,
                          selected: (_selected ?? _defaultId(list)) == o.id,
                          onTap: () => setState(() => _selected = o.id),
                        ),
                      ),
                  ],
                ),
                loading: () => const _OffersSkeleton(),
                error: (Object e, StackTrace _) => Text(
                  'Offres indisponibles pour le moment.',
                  style: MorfoType.bodyMedium,
                ),
              ),
              Gap.h16,
              GradientButton(
                label: _ctaLabel(offers),
                icon: _currentOffer(offers)?.hasTrial ?? false
                    ? Icons.lock_open_rounded
                    : null,
                loading: _busy,
                onPressed: offers.hasValue
                    ? () => _subscribe(offers.requireValue)
                    : null,
              ),
              Gap.h8,
              if (_currentOffer(offers)?.hasTrial ?? false)
                _TrialLine(offer: _currentOffer(offers)!),
              Gap.h8,
              const _SubscriptionDisclosure(),
              Gap.h8,
              Center(
                child: TextButton(
                  onPressed: _restore,
                  child: Text('Restaurer les achats', style: MorfoType.label),
                ),
              ),
              const _LegalRow(),
            ],
          ),
          Positioned(
            top: 4,
            left: 0,
            child: IconButton(
              onPressed: () => context.go('/home'),
              icon: const Icon(Icons.close, color: MorfoColors.muted),
            ),
          ),
        ],
      ),
    );
  }

  String _defaultId(List<SubscriptionOffer> list) => list
      .firstWhere((SubscriptionOffer o) => o.highlighted,
          orElse: () => list.first)
      .id;

  /// Offre actuellement sélectionnée (ou celle par défaut).
  SubscriptionOffer? _currentOffer(
      AsyncValue<List<SubscriptionOffer>> offers) {
    if (!offers.hasValue) return null;
    final List<SubscriptionOffer> list = offers.requireValue;
    if (list.isEmpty) return null;
    final String id = _selected ?? _defaultId(list);
    return list.where((SubscriptionOffer o) => o.id == id).firstOrNull;
  }

  String _ctaLabel(AsyncValue<List<SubscriptionOffer>> offers) {
    final SubscriptionOffer? o = _currentOffer(offers);
    if (o != null && o.hasTrial) {
      return 'Commencer mes ${o.trialDays} jours gratuits';
    }
    return 'Continuer';
  }
}

/// Ligne rassurante sous le CTA quand l'offre inclut un essai gratuit.
class _TrialLine extends StatelessWidget {
  const _TrialLine({required this.offer});
  final SubscriptionOffer offer;

  @override
  Widget build(BuildContext context) {
    return Text(
      'Gratuit pendant ${offer.trialDays} jours, puis ${offer.price}. '
      'Annule quand tu veux, sans frais.',
      textAlign: TextAlign.center,
      style: MorfoType.caption.copyWith(color: MorfoColors.ink),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.md),
      child: Row(
        children: <Widget>[
          Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: MorfoColors.holoGradient,
            ),
            child: const Icon(Icons.check, size: 16, color: MorfoColors.voidColor),
          ),
          Gap.w12,
          Expanded(child: Text(text, style: MorfoType.bodyLarge)),
        ],
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({
    required this.offer,
    required this.selected,
    required this.onTap,
  });
  final SubscriptionOffer offer;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.99,
      child: AnimatedContainer(
        duration: Motion.fast,
        padding: const EdgeInsets.all(Gap.lg),
        decoration: BoxDecoration(
          color: MorfoColors.surface2.withValues(alpha: 0.6),
          borderRadius: Radii.brLg,
          border: Border.all(
            color: selected
                ? MorfoColors.holoViolet
                : MorfoColors.stroke,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: <Widget>[
            _RadioDot(selected: selected),
            Gap.w12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(offer.title, style: MorfoType.titleSmall),
                      if (offer.hasTrial) ...<Widget>[
                        Gap.w8,
                        _TrialBadge(days: offer.trialDays),
                      ] else if (offer.highlighted) ...<Widget>[
                        Gap.w8,
                        const _PopularBadge(),
                      ],
                    ],
                  ),
                  if (offer.hasTrial)
                    Text('${offer.trialDays} jours gratuits, puis ${offer.price}',
                        style: MorfoType.caption)
                  else if (offer.subtitle.isNotEmpty)
                    Text(offer.subtitle, style: MorfoType.caption),
                ],
              ),
            ),
            Text(offer.price, style: MorfoType.titleSmall),
          ],
        ),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected});
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? MorfoColors.holoViolet : MorfoColors.muted,
          width: 2,
        ),
      ),
      child: selected
          ? const Padding(
              padding: EdgeInsets.all(3),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: MorfoColors.holoGradient,
                ),
              ),
            )
          : null,
    );
  }
}

class _TrialBadge extends StatelessWidget {
  const _TrialBadge({required this.days});
  final int days;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        gradient: MorfoColors.holoGradient,
        borderRadius: BorderRadius.circular(Radii.pill),
      ),
      child: Text(
        '$days JOURS GRATUITS',
        style: MorfoType.eyebrow.copyWith(
          color: MorfoColors.voidColor,
          fontSize: 10,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _PopularBadge extends StatelessWidget {
  const _PopularBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        gradient: MorfoColors.holoGradient,
        borderRadius: BorderRadius.circular(Radii.pill),
      ),
      child: Text(
        'POPULAIRE',
        style: MorfoType.eyebrow.copyWith(
          color: MorfoColors.voidColor,
          fontSize: 10,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _OffersSkeleton extends StatelessWidget {
  const _OffersSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: <Widget>[
        ShimmerSkeleton(height: 74, borderRadius: Radii.brLg),
        SizedBox(height: Gap.md),
        ShimmerSkeleton(height: 74, borderRadius: Radii.brLg),
      ],
    );
  }
}

/// Mention d'abonnement exigée par Apple (renouvellement auto, prix/période,
/// gestion). Le détail exact du prix est affiché sur chaque offre au-dessus.
class _SubscriptionDisclosure extends StatelessWidget {
  const _SubscriptionDisclosure();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Abonnement à renouvellement automatique. Le paiement est prélevé sur '
      'ton compte Apple à la confirmation. Il se renouvelle sauf annulation au '
      'moins 24 h avant la fin de la période ; gère-le à tout moment dans les '
      'Réglages de ton compte App Store.',
      textAlign: TextAlign.center,
      style: MorfoType.caption,
    );
  }
}

class _LegalRow extends StatelessWidget {
  const _LegalRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Gap.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          TextButton(
            onPressed: () => context.push('/terms'),
            child: Text('Conditions', style: MorfoType.caption),
          ),
          Text('·', style: MorfoType.caption),
          TextButton(
            onPressed: () => context.push('/privacy'),
            child: Text('Confidentialité', style: MorfoType.caption),
          ),
        ],
      ),
    );
  }
}
