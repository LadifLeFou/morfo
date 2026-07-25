import 'package:flutter/material.dart';

/// Le logo papillon Morfo.
///
/// L'image source (`mascot.png`) a un fond transparent : elle se pose
/// directement sur n'importe quel fond, sans traitement. (Auparavant le fichier
/// avait un fond sombre carré qu'il fallait estomper au masque radial ; ce
/// n'est plus nécessaire depuis le logo épuré.)
class MorfoMascot extends StatelessWidget {
  const MorfoMascot({super.key, required this.size, this.opacity = 1.0});

  /// Côté du carré occupé par le logo, en points logiques.
  final double size;

  /// Opacité globale — utile en filigrane derrière un autre élément.
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final Widget image = Image.asset(
      'assets/images/mascot.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      errorBuilder: (BuildContext _, Object _, StackTrace? _) =>
          const SizedBox.shrink(),
    );
    return opacity >= 1.0 ? image : Opacity(opacity: opacity, child: image);
  }
}
