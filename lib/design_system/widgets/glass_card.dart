import 'dart:ui';

import 'package:flutter/material.dart';

import '../morfo_colors.dart';
import '../morfo_spacing.dart';

/// Surface « verre » : fond translucide, bordure hairline, coins arrondis.
///
/// [blur] active un flou d'arrière-plan (plus coûteux) — à réserver aux sheets.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(Gap.lg),
    this.borderRadius = Radii.brLg,
    this.blur = false,
    this.color,
    this.border = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final bool blur;
  final Color? color;
  final bool border;

  @override
  Widget build(BuildContext context) {
    final Widget content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? MorfoColors.surface2.withValues(alpha: 0.66),
        borderRadius: borderRadius,
        border: border
            ? Border.all(color: MorfoColors.stroke, width: 1)
            : null,
      ),
      child: child,
    );

    if (!blur) return content;
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: content,
      ),
    );
  }
}
