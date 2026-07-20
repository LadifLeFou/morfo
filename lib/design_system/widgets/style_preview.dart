import 'package:flutter/material.dart';

import '../morfo_colors.dart';
import '../morfo_typography.dart';
import '../../core/strings.dart';

/// Aperçu animé « avant → après » d'un style : une poignée balaie l'image en
/// boucle pour révéler la transformation, avec des labels AVANT / APRÈS clairs.
class StylePreview extends StatefulWidget {
  const StylePreview({
    super.key,
    required this.beforeAsset,
    required this.afterAsset,
    this.fallback,
    this.showTags = true,
    this.borderRadius = BorderRadius.zero,
  });

  final String beforeAsset;
  final String afterAsset;

  /// Affiché si l'image « après » n'a pas pu être chargée.
  final Widget? fallback;
  final bool showTags;
  final BorderRadius borderRadius;

  @override
  State<StylePreview> createState() => _StylePreviewState();
}

class _StylePreviewState extends State<StylePreview>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3400),
  )..repeat(reverse: true);

  late final Animation<double> _anim =
      CurvedAnimation(parent: _c, curve: Curves.easeInOut);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Widget _img(String asset, {Widget? fallback}) => Image.asset(
        asset,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (BuildContext _, Object _, StackTrace? _) =>
            fallback ?? const ColoredBox(color: MorfoColors.surface2),
      );

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: widget.borderRadius,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints cons) {
            final double w = cons.maxWidth;
            final double h = cons.maxHeight;
            return AnimatedBuilder(
              animation: _anim,
              builder: (BuildContext context, Widget? _) {
                final double f = 0.24 + 0.52 * _anim.value;
                return Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    _img(widget.afterAsset, fallback: widget.fallback),
                    ClipRect(
                      clipper: _LeftClip(f),
                      child: _img(widget.beforeAsset),
                    ),
                    // Ligne de balayage
                    Positioned(
                      left: f * w - 1,
                      top: 0,
                      bottom: 0,
                      width: 2,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: MorfoColors.ink.withValues(alpha: 0.9),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: MorfoColors.holoViolet.withValues(alpha: 0.6),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Poignée
                    Positioned(
                      left: f * w - 15,
                      top: h / 2 - 15,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: MorfoColors.voidColor.withValues(alpha: 0.6),
                          border: Border.all(
                            color: MorfoColors.ink.withValues(alpha: 0.9),
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(Icons.compare_arrows,
                            size: 15, color: MorfoColors.ink),
                      ),
                    ),
                    if (widget.showTags) ...<Widget>[
                      Positioned(left: 8, top: 8, child: _tag(S.before)),
                      Positioned(right: 8, top: 8, child: _tag(S.after)),
                    ],
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _tag(String s) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: MorfoColors.voidColor.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: MorfoColors.stroke),
        ),
        child: Text(
          s,
          style: MorfoType.eyebrow.copyWith(fontSize: 10, letterSpacing: 1.2),
        ),
      );
}

class _LeftClip extends CustomClipper<Rect> {
  _LeftClip(this.f);
  final double f;

  @override
  Rect getClip(Size size) => Rect.fromLTWH(0, 0, size.width * f, size.height);

  @override
  bool shouldReclip(_LeftClip old) => old.f != f;
}
