import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/template.dart';
import '../../../design_system/design_system.dart';
import '../template_icon.dart';

/// Détail d'un template — grand aperçu (Hero), description, coût, CTA.
class TemplateDetailScreen extends StatelessWidget {
  const TemplateDetailScreen({super.key, required this.template});

  final Template template;

  @override
  Widget build(BuildContext context) {
    final int cost = template.creditCost;
    final String costLabel = template.isVideo
        ? 'Vidéo · $cost crédits'
        : '$cost crédit${cost > 1 ? 's' : ''}';

    return MorfoScaffold(
      glow: false,
      safeTop: false,
      body: Stack(
        children: <Widget>[
          ListView(
            padding: const EdgeInsets.only(bottom: 128),
            children: <Widget>[
              AspectRatio(
                aspectRatio: 4 / 5,
                child: HoloCard(
                  borderRadius: 0,
                  eyebrow: template.category.label,
                  child: Hero(
                    tag: 'tpl_${template.id}',
                    child: HoloPlaceholder(
                      seed: template.id,
                      icon: iconForTemplate(template),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(Gap.xl, Gap.xxl, Gap.xl, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(template.title, style: MorfoType.displayMedium),
                    Gap.h12,
                    _CostChip(label: costLabel),
                    Gap.h24,
                    Text(
                      template.description,
                      style: MorfoType.bodyLarge
                          .copyWith(color: MorfoColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Bouton retour
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(Gap.sm),
              child: _CircleButton(
                icon: Icons.arrow_back,
                onTap: () => context.pop(),
              ),
            ),
          ),
          // CTA épinglé en bas
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(Gap.xl, Gap.xxl, Gap.xl, Gap.xxl),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[Color(0x0007060D), MorfoColors.voidColor],
                ),
              ),
              child: GradientButton(
                label: 'Utiliser cette photo',
                icon: Icons.add_a_photo_outlined,
                onPressed: () => context.push('/import', extra: template),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CostChip extends StatelessWidget {
  const _CostChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Gap.md, vertical: Gap.sm),
      decoration: BoxDecoration(
        color: MorfoColors.surface2.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(Radii.pill),
        border: Border.all(color: MorfoColors.stroke),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.bolt, size: 15, color: MorfoColors.holoWarm),
          const SizedBox(width: 5),
          Text(label, style: MorfoType.label),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.9,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: MorfoColors.voidColor.withValues(alpha: 0.5),
          border: Border.all(color: MorfoColors.stroke),
        ),
        child: Icon(icon, size: 20, color: MorfoColors.ink),
      ),
    );
  }
}
