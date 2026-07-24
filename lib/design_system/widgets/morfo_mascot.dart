import 'package:flutter/material.dart';

/// La mascotte papillon, ses bords fondus dans le fond.
///
/// Le fichier source `mascot.png` a un fond sombre carré et un cadre néon :
/// affiché tel quel, il laisse un vilain carré visible sur les fonds clairs
/// comme dans l'en-tête d'accueil. Un masque radial estompe la bordure pour ne
/// garder que le papillon, quel que soit le fond.
///
/// Centralise un traitement qui était dupliqué dans le splash et l'écran de
/// génération.
class MorfoMascot extends StatelessWidget {
  const MorfoMascot({super.key, required this.size, this.opacity = 1.0});

  /// Côté du carré occupé par la mascotte, en points logiques.
  final double size;

  /// Opacité globale — utile en filigrane derrière un autre élément.
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final Widget masque = ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (Rect r) => const RadialGradient(
        colors: <Color>[Colors.white, Colors.white, Colors.transparent],
        // Plein jusqu'à 60 % du rayon, puis fondu : le papillon reste net, le
        // cadre carré disparaît.
        stops: <double>[0.0, 0.60, 0.82],
      ).createShader(r),
      child: Image.asset(
        'assets/images/mascot.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        errorBuilder: (BuildContext _, Object _, StackTrace? _) =>
            const SizedBox.shrink(),
      ),
    );
    return opacity >= 1.0 ? masque : Opacity(opacity: opacity, child: masque);
  }
}
