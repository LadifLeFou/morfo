import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../morfo_colors.dart';
import '../morfo_spacing.dart';

/// Placeholder animé (jamais d'écran blanc au chargement).
class ShimmerSkeleton extends StatelessWidget {
  const ShimmerSkeleton({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius,
  });

  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: MorfoColors.surface2,
        borderRadius: borderRadius ?? Radii.brSm,
      ),
    )
        .animate(onPlay: (AnimationController c) => c.repeat())
        .shimmer(
          duration: 1400.ms,
          color: MorfoColors.ink.withValues(alpha: 0.08),
        );
  }
}
