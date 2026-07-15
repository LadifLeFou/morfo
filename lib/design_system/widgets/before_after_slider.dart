import 'package:flutter/material.dart';

import '../morfo_colors.dart';
import '../morfo_spacing.dart';
import '../morfo_typography.dart';

/// Comparateur avant/après avec poignée glissante.
class BeforeAfterSlider extends StatefulWidget {
  const BeforeAfterSlider({
    super.key,
    required this.before,
    required this.after,
    this.aspectRatio = 3 / 4,
    this.initial = 0.5,
    this.borderRadius,
  });

  final Widget before;
  final Widget after;
  final double aspectRatio;
  final double initial;
  final BorderRadius? borderRadius;

  @override
  State<BeforeAfterSlider> createState() => _BeforeAfterSliderState();
}

class _BeforeAfterSliderState extends State<BeforeAfterSlider> {
  late double _f = widget.initial.clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = widget.borderRadius ?? Radii.brLg;
    return ClipRRect(
      borderRadius: radius,
      child: AspectRatio(
        aspectRatio: widget.aspectRatio,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints cons) {
            final double w = cons.maxWidth;
            final double h = cons.maxHeight;
            final double x = _f * w;
            return GestureDetector(
              onHorizontalDragUpdate: (DragUpdateDetails d) =>
                  setState(() => _f = (_f + d.delta.dx / w).clamp(0.0, 1.0)),
              onTapDown: (TapDownDetails d) => setState(
                () => _f = (d.localPosition.dx / w).clamp(0.0, 1.0),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Positioned.fill(child: widget.after),
                  Positioned.fill(
                    child: ClipRect(
                      clipper: _LeftClipper(_f),
                      child: widget.before,
                    ),
                  ),
                  Positioned(
                    left: x - 1,
                    top: 0,
                    bottom: 0,
                    width: 2,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: MorfoColors.ink.withValues(alpha: 0.9),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: MorfoColors.holoViolet.withValues(alpha: 0.6),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(left: x - 18, top: h / 2 - 18, child: const _Knob()),
                  Positioned(left: 12, top: 12, child: _tag('AVANT')),
                  Positioned(right: 12, top: 12, child: _tag('APRÈS')),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _tag(String s) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: MorfoColors.voidColor.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(Radii.pill),
        ),
        child: Text(s, style: MorfoType.eyebrow),
      );
}

class _LeftClipper extends CustomClipper<Rect> {
  _LeftClipper(this.f);
  final double f;

  @override
  Rect getClip(Size size) => Rect.fromLTWH(0, 0, size.width * f, size.height);

  @override
  bool shouldReclip(_LeftClipper old) => old.f != f;
}

class _Knob extends StatelessWidget {
  const _Knob();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: MorfoColors.surface2,
        border: Border.all(color: MorfoColors.ink.withValues(alpha: 0.9), width: 2),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: MorfoColors.voidColor.withValues(alpha: 0.5),
            blurRadius: 10,
          ),
        ],
      ),
      child: const Icon(Icons.swap_horiz, size: 18, color: MorfoColors.ink),
    );
  }
}
