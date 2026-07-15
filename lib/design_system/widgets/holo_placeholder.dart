import 'package:flutter/material.dart';

import '../morfo_colors.dart';
import '../morfo_typography.dart';

/// Vignette placeholder déterministe (gradient dérivé d'une graine + teinte holo).
///
/// Sert d'aperçu de template quand aucun asset image n'est fourni — reste dans
/// la palette dark-first plutôt qu'un « template IA générique ».
class HoloPlaceholder extends StatelessWidget {
  const HoloPlaceholder({
    super.key,
    required this.seed,
    this.icon,
    this.label,
  });

  final String seed;
  final IconData? icon;
  final String? label;

  double _hue(int base) => ((base % 360) + 360) % 360;

  @override
  Widget build(BuildContext context) {
    final int base = seed.hashCode;
    final Color a = HSLColor.fromAHSL(1, _hue(base), 0.5, 0.30).toColor();
    final Color b = HSLColor.fromAHSL(1, _hue(base * 5), 0.5, 0.15).toColor();

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[a, b],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: <Color>[
                  MorfoColors.holoViolet.withValues(alpha: 0.10),
                  MorfoColors.holoCyan.withValues(alpha: 0.05),
                ],
              ),
            ),
          ),
          if (icon != null)
            Center(
              child: Icon(
                icon,
                size: 46,
                color: MorfoColors.ink.withValues(alpha: 0.55),
              ),
            ),
          if (label != null)
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(label!, style: MorfoType.eyebrow),
              ),
            ),
        ],
      ),
    );
  }
}
