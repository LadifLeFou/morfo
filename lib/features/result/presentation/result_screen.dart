import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/haptics.dart';
import '../../../core/models/generation_result.dart';
import '../../../design_system/design_system.dart';
import '../../home/template_icon.dart';

/// Résultat — carte holographique signature, avant/après, actions.
class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key, required this.result});

  final GenerationResult result;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => Haptics.success());
  }

  Future<void> _share() async {
    try {
      await SharePlus.instance.share(
        ShareParams(
          text:
              'Ma métamorphose « ${widget.result.templateTitle} » avec Morfo ✨',
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Partage indisponible.')),
        );
      }
    }
  }

  void _save() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Enregistré dans ta galerie.')),
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
        ),
        title: const Text('Ton résultat'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Gap.xl, Gap.sm, Gap.xl, Gap.giant),
        children: <Widget>[
          HoloCard(
            aspectRatio: 3 / 4,
            eyebrow: r.templateTitle,
            title: 'Ta carte',
            child: MorfoImage(url: r.outputUrl, icon: icon),
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
          if (r.sourcePath != null) ...<Widget>[
            Text('Avant / Après', style: MorfoType.titleSmall),
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
                  icon: Icons.download_outlined,
                  label: 'Enregistrer',
                  onTap: _save,
                ),
              ),
              Gap.w12,
              Expanded(
                child: _ActionButton(
                  icon: Icons.ios_share,
                  label: 'Partager',
                  onTap: _share,
                ),
              ),
              Gap.w12,
              Expanded(
                child: _ActionButton(
                  icon: Icons.refresh,
                  label: 'Regénérer',
                  onTap: () => context.pop(),
                ),
              ),
            ],
          ),
          Gap.h24,
          GradientButton(
            label: 'Essayer un autre style',
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
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: Gap.lg),
        decoration: BoxDecoration(
          color: MorfoColors.surface2.withValues(alpha: 0.6),
          borderRadius: Radii.brMd,
          border: Border.all(color: MorfoColors.stroke),
        ),
        child: Column(
          children: <Widget>[
            Icon(icon, size: 22, color: MorfoColors.ink),
            const SizedBox(height: 6),
            Text(label, style: MorfoType.caption.copyWith(color: MorfoColors.ink)),
          ],
        ),
      ),
    );
  }
}
