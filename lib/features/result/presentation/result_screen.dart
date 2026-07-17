import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/haptics.dart';
import '../../../core/models/generation_result.dart';
import '../../../core/strings.dart';
import '../../../design_system/design_system.dart';
import '../../home/template_icon.dart';
import '../../notifications/conversion_notifications.dart';

/// Résultat — carte holographique signature, avant/après, actions.
class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({super.key, required this.result});

  final GenerationResult result;

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => Haptics.success());
  }

  Future<void> _share() async {
    Haptics.light();
    // Élan de partage → relance pour créer une nouvelle carte.
    ref.read(conversionNotificationsProvider).onShared();
    try {
      await SharePlus.instance.share(
        ShareParams(text: S.shareText(widget.result.templateTitle)),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.shareUnavailable)),
        );
      }
    }
  }

  void _save() {
    if (_saved) return;
    Haptics.success();
    setState(() => _saved = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(S.savedToGallery)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final GenerationResult r = widget.result;
    final IconData icon = iconForCategory(r.category);

    return MorfoScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/home'),
          tooltip: 'Fermer',
        ),
        title: Text(S.yourResult),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Gap.xl, Gap.sm, Gap.xl, Gap.giant),
        children: <Widget>[
          HoloCard(
            aspectRatio: 3 / 4,
            eyebrow: r.templateTitle,
            title: S.yourCard,
            interactive: !r.isVideo,
            child: r.isVideo
                ? MorfoVideo(url: r.outputUrl)
                : MorfoImage(url: r.outputUrl, icon: icon),
          )
              .animate()
              .fadeIn(duration: 500.ms)
              .scale(
                begin: const Offset(0.9, 0.9),
                end: const Offset(1, 1),
                duration: 700.ms,
                curve: Curves.easeOutBack,
              )
              .shimmer(
                delay: 300.ms,
                duration: 1200.ms,
                color: MorfoColors.ink.withValues(alpha: 0.5),
              ),
          Gap.h24,
          if (r.sourcePath != null && !r.isVideo) ...<Widget>[
            Text(S.beforeAfter, style: MorfoType.titleSmall),
            Gap.h12,
            BeforeAfterSlider(
              aspectRatio: 3 / 4,
              before: MorfoImage(url: r.sourcePath!, icon: Icons.person_outline),
              after: MorfoImage(url: r.outputUrl, icon: icon),
            ),
            Gap.h24,
          ],
          Row(
            children: <Widget>[
              Expanded(
                child: _ActionButton(
                  icon: _saved ? Icons.check_circle : Icons.download_outlined,
                  label: _saved ? S.saved : S.save,
                  highlighted: _saved,
                  onTap: _save,
                ),
              ),
              Gap.w12,
              Expanded(
                child: _ActionButton(
                  icon: Icons.ios_share,
                  label: S.share,
                  onTap: _share,
                ),
              ),
              Gap.w12,
              Expanded(
                child: _ActionButton(
                  icon: Icons.refresh,
                  label: S.regenerate,
                  onTap: () => context.pop(),
                ),
              ),
            ],
          ),
          Gap.h24,
          GradientButton(
            label: S.tryAnotherStyle,
            icon: Icons.grid_view_rounded,
            onPressed: () => context.go('/home'),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.highlighted = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final Color accent =
        highlighted ? MorfoColors.holoViolet : MorfoColors.ink;
    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Motion.fast,
        padding: const EdgeInsets.symmetric(vertical: Gap.lg),
        decoration: BoxDecoration(
          color: MorfoColors.surface2.withValues(alpha: 0.6),
          borderRadius: Radii.brMd,
          border: Border.all(
            color: highlighted ? MorfoColors.holoViolet : MorfoColors.stroke,
          ),
        ),
        child: Column(
          children: <Widget>[
            Icon(icon, size: 22, color: accent),
            const SizedBox(height: 6),
            Text(label, style: MorfoType.caption.copyWith(color: accent)),
          ],
        ),
      ),
    );
  }
}
