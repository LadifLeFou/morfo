import 'package:flutter/material.dart';

import '../morfo_colors.dart';
import '../morfo_spacing.dart';
import '../morfo_typography.dart';
import 'pressable.dart';

/// CTA primaire — gradient holo, press → scale + haptique.
///
/// L'un des rares endroits où le gradient signature est autorisé.
class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.loading = false,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null && !loading;

    final Widget content = Container(
      height: 56,
      width: expand ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: Gap.xxl),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: MorfoColors.holoGradient,
        borderRadius: Radii.brXl,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: MorfoColors.holoViolet.withValues(alpha: 0.35),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: loading
          ? const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                valueColor: AlwaysStoppedAnimation<Color>(MorfoColors.voidColor),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (icon != null) ...<Widget>[
                  Icon(icon, size: 20, color: MorfoColors.voidColor),
                  Gap.w8,
                ],
                Text(
                  label,
                  style: MorfoType.label.copyWith(
                    color: MorfoColors.voidColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
    );

    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Pressable(
        onTap: enabled ? onPressed : null,
        scale: 0.98,
        child: content,
      ),
    );
  }
}
