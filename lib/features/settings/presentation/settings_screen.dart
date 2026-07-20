import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_state.dart';
import '../../../core/strings.dart';
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
        content: Text(ok ? S.purchasesRestored : S.noPurchasesToRestore),
      ),
    );
  }

  /// Feuille de choix de la langue. La sélection s'applique immédiatement :
  /// `languageProvider` reconstruit tout l'arbre.
  Future<void> _pickLanguage(BuildContext context, WidgetRef ref) async {
    final AppLanguage current = ref.read(languageProvider);

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: MorfoColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.lg)),
      ),
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(Gap.xl, Gap.xl, Gap.xl, Gap.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(S.chooseLanguage.toUpperCase(), style: MorfoType.eyebrow),
                Gap.h16,
                for (final AppLanguage language in AppLanguage.values)
                  _SettingTile(
                    icon: language == current
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    title: language.label,
                    onTap: () {
                      ref.read(languageProvider.notifier).select(language);
                      Navigator.of(sheetContext).pop();
                    },
                  ),
              ],
            ),
          ),
        );
      },
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
          tooltip: S.back,
        ),
        title: Text(S.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Gap.xl, Gap.sm, Gap.xl, Gap.giant),
        children: <Widget>[
          _SectionHeader(S.subscription),
          if (subscribed)
            _SettingTile(
              icon: Icons.verified_outlined,
              title: S.subActive,
              subtitle: S.thanksSupport,
            )
          else
            _SettingTile(
              icon: Icons.auto_awesome,
              title: S.subscribe,
              subtitle: S.subPitch,
              onTap: () => context.push('/paywall'),
            ),
          _SettingTile(
            icon: Icons.restore,
            title: S.restore,
            onTap: () => _restore(ref, context),
          ),
          Gap.h24,
          _SectionHeader(S.preferences),
          _SettingTile(
            icon: Icons.language,
            title: S.language,
            trailing: Text(ref.watch(languageProvider).label,
                style: MorfoType.label),
            onTap: () => _pickLanguage(context, ref),
          ),
          Gap.h24,
          _SectionHeader(S.about),
          _SettingTile(
            icon: Icons.description_outlined,
            title: S.termsOfUse,
            onTap: () => context.push('/terms'),
          ),
          _SettingTile(
            icon: Icons.shield_outlined,
            title: S.privacy,
            onTap: () => context.push('/privacy'),
          ),
          _SettingTile(
            icon: Icons.mail_outline,
            title: S.contact,
            subtitle: 'support@morfo.app',
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(S.contactUs('support@morfo.app')),
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
