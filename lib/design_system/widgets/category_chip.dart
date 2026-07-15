import 'package:flutter/material.dart';

import '../morfo_colors.dart';
import '../morfo_spacing.dart';
import '../morfo_typography.dart';
import 'pressable.dart';

/// Chip de catégorie (Épique, Rétro, Fun…) — état sélectionné discret.
class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.95,
      child: AnimatedContainer(
        duration: Motion.fast,
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(
          horizontal: Gap.lg,
          vertical: Gap.sm + 2,
        ),
        decoration: BoxDecoration(
          color: selected
              ? MorfoColors.ink.withValues(alpha: 0.06)
              : MorfoColors.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(Radii.pill),
          border: Border.all(
            color: selected
                ? MorfoColors.holoViolet.withValues(alpha: 0.85)
                : MorfoColors.stroke,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Text(
          label,
          style: MorfoType.label.copyWith(
            color: selected ? MorfoColors.ink : MorfoColors.muted,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
