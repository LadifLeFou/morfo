import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_state.dart';
import '../../../design_system/design_system.dart';
import '../../../services/purchases_service.dart';

/// Réglages — abonnement, restauration, langue, liens légaux, version.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _restore(WidgetRef ref, BuildContext context) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final SubscriptionNotifier sub = ref.read(subscriptionProvider.notifier);
    final bool ok = await ref.read(purchasesServiceProvider).restore();
    if (ok) sub.setSubscribed(true);
    messenger.showSnackBar(
      SnackBar(
        content: Text(ok ? 'Achats restaurés.' : 'Aucun achat à restaurer.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool subscribed = ref.watch(subscriptionProvider);

    return MorfoScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
          tooltip: 'Retour',
        ),
        title: const Text('Réglages'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Gap.xl, Gap.sm, Gap.xl, Gap.giant),
        children: <Widget>[
          const _SectionHeader('Abonnement'),
          if (subscribed)
            const _SettingTile(
              icon: Icons.verified_outlined,
              title: 'Abonnement actif',
              subtitle: 'Merci de soutenir Morfo.',
            )
          else
            _SettingTile(
              icon: Icons.auto_awesome,
              title: 'S’abonner',
              subtitle: '3,99 €/sem · 650 crédits chaque semaine.',
              onTap: () => context.push('/paywall'),
            ),
          _SettingTile(
            icon: Icons.restore,
            title: 'Restaurer les achats',
            onTap: () => _restore(ref, context),
          ),
          Gap.h24,
          const _SectionHeader('Préférences'),
          const _SettingTile(
            icon: Icons.language,
            title: 'Langue',
            trailing: Text('Français', style: MorfoType.label),
          ),
          Gap.h24,
          const _SectionHeader('À propos'),
          _SettingTile(
            icon: Icons.description_outlined,
            title: 'Conditions d’utilisation',
            onTap: () => context.push('/terms'),
          ),
          _SettingTile(
            icon: Icons.shield_outlined,
            title: 'Confidentialité',
            onTap: () => context.push('/privacy'),
          ),
          _SettingTile(
            icon: Icons.mail_outline,
            title: 'Contact',
            subtitle: 'support@morfo.app',
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Écris-nous à support@morfo.app'),
              ),
            ),
          ),
          Gap.h32,
          Center(
            child: Text('Morfo · Version 1.0.0', style: MorfoType.caption),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.sm, left: Gap.xs),
      child: Text(title.toUpperCase(), style: MorfoType.eyebrow),
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.sm),
      child: Pressable(
        onTap: onTap,
        scale: 0.99,
        haptic: onTap != null,
        child: Container(
          padding: const EdgeInsets.all(Gap.lg),
          decoration: BoxDecoration(
            color: MorfoColors.surface2.withValues(alpha: 0.5),
            borderRadius: Radii.brMd,
            border: Border.all(color: MorfoColors.stroke),
          ),
          child: Row(
            children: <Widget>[
              Icon(icon, size: 22, color: MorfoColors.holoViolet),
              Gap.w16,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(title, style: MorfoType.label),
                    if (subtitle != null) ...<Widget>[
                      const SizedBox(height: 2),
                      Text(subtitle!, style: MorfoType.caption),
                    ],
                  ],
                ),
              ),
              ?trailing,
              if (onTap != null && trailing == null)
                const Icon(Icons.chevron_right,
                    size: 20, color: MorfoColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}
