import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_state.dart';
import '../../../core/haptics.dart';
import '../../../design_system/design_system.dart';
import '../../../services/purchases_service.dart';
import '../../../core/strings.dart';

final FutureProvider<List<CreditPack>> _creditPacksProvider =
    FutureProvider<List<CreditPack>>(
  (Ref ref) => ref.read(purchasesServiceProvider).creditPacks(),
);

/// Boutique de crédits — solde en chiffres tabulaires, packs, meilleur ratio.
class CreditsScreen extends ConsumerWidget {
  const CreditsScreen({super.key});

  Future<void> _buy(WidgetRef ref, BuildContext context, CreditPack pack) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final CreditsNotifier credits = ref.read(creditsProvider.notifier);
    final bool ok =
        await ref.read(purchasesServiceProvider).purchaseCredits(pack.id);
    if (ok) {
      Haptics.success();
      credits.add(pack.credits);
      messenger.showSnackBar(
        SnackBar(content: Text(S.creditsAdded(pack.credits))),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int balance = ref.watch(creditsProvider);
    final AsyncValue<List<CreditPack>> packs = ref.watch(_creditPacksProvider);

    return MorfoScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
          tooltip: S.back,
        ),
        title: Text(S.credits),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Gap.xl, Gap.sm, Gap.xl, Gap.giant),
        children: <Widget>[
          _BalanceCard(balance: balance),
          Gap.h32,
          Text(S.recharge, style: MorfoType.titleSmall),
          Gap.h16,
          packs.when(
            data: (List<CreditPack> list) => Column(
              children: <Widget>[
                for (final CreditPack p in list)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Gap.md),
                    child: _PackCard(
                      pack: p,
                      onTap: () => _buy(ref, context, p),
                    ),
                  ),
              ],
            ),
            loading: () => const Column(
              children: <Widget>[
                ShimmerSkeleton(height: 70, borderRadius: Radii.brLg),
                SizedBox(height: Gap.md),
                ShimmerSkeleton(height: 70, borderRadius: Radii.brLg),
              ],
            ),
            error: (Object e, StackTrace _) =>
                Text(S.packsUnavailable, style: MorfoType.bodyMedium),
          ),
          Gap.h16,
          Text(
            'Ton abonnement recharge tes crédits chaque semaine. '
            'Les packs s’ajoutent à ton solde.',
            style: MorfoType.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.balance});
  final int balance;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Gap.xxl),
      decoration: BoxDecoration(
        borderRadius: Radii.brLg,
        border: Border.all(color: MorfoColors.stroke),
        gradient: LinearGradient(
          colors: <Color>[
            MorfoColors.holoViolet.withValues(alpha: 0.16),
            MorfoColors.holoCyan.withValues(alpha: 0.06),
          ],
        ),
      ),
      child: Column(
        children: <Widget>[
          Text(S.yourBalance, style: MorfoType.eyebrow),
          Gap.h12,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(Icons.bolt, size: 34, color: MorfoColors.holoWarm),
              const SizedBox(width: 6),
              Text('$balance',
                  style: MorfoType.credits.copyWith(fontSize: 52)),
            ],
          ),
          Gap.h4,
          Text(S.creditsAvailable, style: MorfoType.caption),
        ],
      ),
    );
  }
}

class _PackCard extends StatelessWidget {
  const _PackCard({required this.pack, required this.onTap});
  final CreditPack pack;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.99,
      child: Container(
        padding: const EdgeInsets.all(Gap.lg),
        decoration: BoxDecoration(
          color: MorfoColors.surface2.withValues(alpha: 0.6),
          borderRadius: Radii.brLg,
          border: Border.all(
            color: pack.bestValue ? MorfoColors.holoViolet : MorfoColors.stroke,
            width: pack.bestValue ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: <Widget>[
            const Icon(Icons.bolt, size: 22, color: MorfoColors.holoWarm),
            Gap.w12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(pack.title, style: MorfoType.titleSmall),
                      if (pack.bestValue) ...<Widget>[
                        Gap.w8,
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            gradient: MorfoColors.holoGradient,
                            borderRadius: BorderRadius.circular(Radii.pill),
                          ),
                          child: Text(
                            'MEILLEUR RATIO',
                            style: MorfoType.eyebrow.copyWith(
                              color: MorfoColors.voidColor,
                              fontSize: 10,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Text(pack.price, style: MorfoType.titleSmall),
          ],
        ),
      ),
    );
  }
}
