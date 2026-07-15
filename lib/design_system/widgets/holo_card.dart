import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../morfo_colors.dart';
import '../morfo_spacing.dart';
import '../morfo_typography.dart';
import 'pressable.dart';

/// Carte holographique — signature de Morfo.
///
/// L'image est présentée comme une carte à collectionner : cadre verre, overlay
/// « foil » spectral réactif à l'inclinaison (gyroscope sur mobile, survol souris
/// sur le web), grain léger et balayage spéculaire. Respecte `reduce motion`.
class HoloCard extends StatefulWidget {
  const HoloCard({
    super.key,
    required this.child,
    this.eyebrow,
    this.title,
    this.onTap,
    this.borderRadius = Radii.lg,
    this.interactive = true,
    this.aspectRatio,
  });

  final Widget child;
  final String? eyebrow;
  final String? title;
  final VoidCallback? onTap;
  final double borderRadius;
  final bool interactive;
  final double? aspectRatio;

  @override
  State<HoloCard> createState() => _HoloCardState();
}

class _HoloCardState extends State<HoloCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ambient =
      AnimationController(vsync: this, duration: const Duration(seconds: 9))
        ..repeat();
  StreamSubscription<AccelerometerEvent>? _accel;
  Offset _sensorTilt = Offset.zero;
  Offset _pointerTilt = Offset.zero;

  @override
  void initState() {
    super.initState();
    if (widget.interactive) _subscribeSensor();
  }

  void _subscribeSensor() {
    try {
      _accel = accelerometerEventStream().listen(
        (AccelerometerEvent e) {
          // Portrait : x ≈ inclinaison gauche/droite, y ≈ haut/bas.
          _sensorTilt = Offset(
            (-e.x / 7).clamp(-1.0, 1.0),
            ((e.y - 4) / 7).clamp(-1.0, 1.0),
          );
        },
        onError: (Object _) {},
        cancelOnError: false,
      );
    } catch (_) {
      // Capteur indisponible (web/desktop) : survol souris + ambiant prennent le relais.
    }
  }

  @override
  void dispose() {
    _accel?.cancel();
    _ambient.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool reduce = MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    Widget frame = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints c) {
        final double width = c.hasBoundedWidth ? c.maxWidth : 320;
        final double height = c.hasBoundedHeight ? c.maxHeight : width * 1.3;
        return MouseRegion(
          onHover: (widget.interactive && !reduce)
              ? (PointerHoverEvent e) {
                  _pointerTilt = Offset(
                    (e.localPosition.dx / width * 2 - 1).clamp(-1.0, 1.0),
                    (e.localPosition.dy / height * 2 - 1).clamp(-1.0, 1.0),
                  );
                }
              : null,
          onExit: (_) => _pointerTilt = Offset.zero,
          child: reduce
              ? _card(Offset.zero)
              : AnimatedBuilder(
                  animation: _ambient,
                  builder: (BuildContext context, _) {
                    final double t = _ambient.value * 2 * math.pi;
                    final Offset ambient =
                        Offset(math.sin(t), math.cos(t)) * 0.12;
                    final Offset tilt = Offset(
                      (_pointerTilt.dx + _sensorTilt.dx + ambient.dx)
                          .clamp(-1.0, 1.0),
                      (_pointerTilt.dy + _sensorTilt.dy + ambient.dy)
                          .clamp(-1.0, 1.0),
                    );
                    return _card(tilt);
                  },
                ),
        );
      },
    );

    if (widget.aspectRatio != null) {
      frame = AspectRatio(aspectRatio: widget.aspectRatio!, child: frame);
    }
    return Pressable(onTap: widget.onTap, scale: 0.98, child: frame);
  }

  Widget _card(Offset tilt) {
    final BorderRadius radius = BorderRadius.circular(widget.borderRadius);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: MorfoColors.holoViolet
                .withValues(alpha: 0.25 + 0.15 * tilt.dx.abs()),
            blurRadius: 40,
            spreadRadius: -6,
            offset: Offset(tilt.dx * 10, 12 + tilt.dy * 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            // 1 · Image / visuel
            Positioned.fill(child: widget.child),
            // 2 · Foil spectral (les bandes glissent avec l'inclinaison)
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(-1 - tilt.dx, -1 - tilt.dy),
                      end: Alignment(1 - tilt.dx, 1 - tilt.dy),
                      tileMode: TileMode.mirror,
                      colors: <Color>[
                        MorfoColors.holoCyan.withValues(alpha: 0.26),
                        MorfoColors.holoViolet.withValues(alpha: 0.20),
                        MorfoColors.holoPink.withValues(alpha: 0.26),
                        MorfoColors.holoWarm.withValues(alpha: 0.22),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // 3 · Balayage spéculaire
            Positioned.fill(
              child: IgnorePointer(
                child: Align(
                  alignment: Alignment(tilt.dx * 1.4, tilt.dy * 1.4),
                  child: FractionallySizedBox(
                    widthFactor: 0.5,
                    heightFactor: 1.6,
                    child: Transform.rotate(
                      angle: -0.6,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: <Color>[
                              Colors.white.withValues(alpha: 0.0),
                              Colors.white.withValues(alpha: 0.12),
                              Colors.white.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // 4 · Grain léger
            const Positioned.fill(
              child: IgnorePointer(
                child: RepaintBoundary(
                  child: CustomPaint(painter: _GrainPainter()),
                ),
              ),
            ),
            // 5 · Scrim + eyebrow/titre
            if (widget.eyebrow != null || widget.title != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: IgnorePointer(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(
                        Gap.lg, Gap.xxl, Gap.lg, Gap.lg),
                    decoration: const BoxDecoration(gradient: MorfoColors.scrim),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        if (widget.eyebrow != null)
                          Text(widget.eyebrow!.toUpperCase(),
                              style: MorfoType.eyebrow),
                        if (widget.title != null) ...<Widget>[
                          const SizedBox(height: 4),
                          Text(widget.title!, style: MorfoType.titleMedium),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            // 6 · Cadre verre
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: radius,
                    border: Border.all(
                      color: MorfoColors.ink.withValues(alpha: 0.12),
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GrainPainter extends CustomPainter {
  const _GrainPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final math.Random rng = math.Random(42);
    final Paint p = Paint()..color = Colors.white.withValues(alpha: 0.035);
    final int count =
        ((size.width * size.height) / 900).clamp(80, 400).toInt();
    for (int i = 0; i < count; i++) {
      canvas.drawCircle(
        Offset(rng.nextDouble() * size.width, rng.nextDouble() * size.height),
        0.6,
        p,
      );
    }
  }

  @override
  bool shouldRepaint(_GrainPainter oldDelegate) => false;
}
