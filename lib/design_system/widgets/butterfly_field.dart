import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../morfo_colors.dart';

/// Nuée de papillons dérivant lentement en fond.
///
/// Chaque papillon monte, ondule et bat des ailes à son propre rythme. Utilisé
/// discrètement sur le splash et plus présent sur l'écran de génération, où il
/// fait patienter pendant la génération.
///
/// [intensity] multiplie l'opacité de base : 1 pour l'ambiance à peine visible
/// du splash, 3-4 pour un fond assumé pendant le chargement.
class ButterflyField extends StatefulWidget {
  const ButterflyField({
    super.key,
    required this.reduce,
    this.count = 9,
    this.intensity = 1.0,
    this.cycle = const Duration(seconds: 26),
  });

  /// Respecte « reduce motion » : fige la scène sur son état initial.
  final bool reduce;

  /// Nombre de papillons dessinés.
  final int count;

  /// Multiplicateur d'opacité (1 = discret, 3+ = bien visible).
  final double intensity;

  /// Durée d'un cycle complet de dérive verticale.
  final Duration cycle;

  @override
  State<ButterflyField> createState() => _ButterflyFieldState();
}

class _ButterflyFieldState extends State<ButterflyField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: widget.cycle);

  late List<_Butterfly> _butterflies = _seed();

  List<_Butterfly> _seed() {
    // Graine fixe : la composition reste identique d'un lancement à l'autre.
    final math.Random rnd = math.Random(7);
    const List<Color> tints = <Color>[
      MorfoColors.holoViolet,
      MorfoColors.holoPink,
      MorfoColors.holoCyan,
    ];
    return List<_Butterfly>.generate(widget.count, (int i) {
      return _Butterfly(
        x: rnd.nextDouble(),
        y: rnd.nextDouble(),
        size: 16 + rnd.nextDouble() * 26,
        phase: rnd.nextDouble() * math.pi * 2,
        swayAmp: 0.02 + rnd.nextDouble() * 0.05,
        flapSpeed: 5 + rnd.nextDouble() * 4,
        tilt: (rnd.nextDouble() - 0.5) * 0.6,
        tint: tints[i % tints.length],
        opacity: (0.04 + rnd.nextDouble() * 0.045) * widget.intensity,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    if (!widget.reduce) _c.repeat();
  }

  @override
  void didUpdateWidget(ButterflyField old) {
    super.didUpdateWidget(old);
    if (old.count != widget.count || old.intensity != widget.intensity) {
      _butterflies = _seed();
    }
    if (old.cycle != widget.cycle) _c.duration = widget.cycle;
    if (old.reduce != widget.reduce) {
      widget.reduce ? _c.stop() : _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _c,
          builder: (BuildContext context, Widget? _) {
            return CustomPaint(
              painter: _ButterflyPainter(
                butterflies: _butterflies,
                t: widget.reduce ? 0.0 : _c.value,
              ),
              size: Size.infinite,
            );
          },
        ),
      ),
    );
  }
}

/// Paramètres d'un papillon de fond.
class _Butterfly {
  const _Butterfly({
    required this.x,
    required this.y,
    required this.size,
    required this.phase,
    required this.swayAmp,
    required this.flapSpeed,
    required this.tilt,
    required this.tint,
    required this.opacity,
  });

  final double x; // position horizontale de base (0..1)
  final double y; // position verticale de base (0..1)
  final double size; // envergure en px
  final double phase; // déphasage individuel
  final double swayAmp; // amplitude d'ondulation horizontale
  final double flapSpeed; // vitesse de battement
  final double tilt; // inclinaison en radians
  final Color tint;
  final double opacity;
}

class _ButterflyPainter extends CustomPainter {
  _ButterflyPainter({required this.butterflies, required this.t});

  final List<_Butterfly> butterflies;
  final double t; // 0..1, boucle

  @override
  void paint(Canvas canvas, Size size) {
    final double angle = t * 2 * math.pi;

    for (final _Butterfly b in butterflies) {
      // Dérive verticale (monte) + ondulation horizontale.
      final double dy = ((b.y - t) % 1.0 + 1.0) % 1.0;
      final double dx = (b.x + b.swayAmp * math.sin(angle + b.phase)) % 1.0;

      canvas.save();
      canvas.translate(dx * size.width, dy * size.height);
      canvas.rotate(b.tilt);
      // Battement d'ailes : facteur d'ouverture 0.3..1.
      _paintButterfly(
        canvas,
        b,
        0.3 + 0.7 * (0.5 + 0.5 * math.sin(angle * b.flapSpeed + b.phase)),
      );
      canvas.restore();
    }
  }

  void _paintButterfly(Canvas canvas, _Butterfly b, double flap) {
    final double s = b.size;
    final Paint paint = Paint()
      ..color = b.tint.withValues(alpha: b.opacity.clamp(0.0, 1.0))
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2);

    final double wingW = s * 0.5 * flap; // ailes qui « respirent »

    // Ailes supérieures.
    _wing(canvas, paint,
        dx: wingW * 0.55, dy: -s * 0.12, rx: wingW * 0.6, ry: s * 0.5);
    _wing(canvas, paint,
        dx: -wingW * 0.55, dy: -s * 0.12, rx: wingW * 0.6, ry: s * 0.5);
    // Ailes inférieures (plus petites).
    _wing(canvas, paint,
        dx: wingW * 0.42, dy: s * 0.3, rx: wingW * 0.48, ry: s * 0.4);
    _wing(canvas, paint,
        dx: -wingW * 0.42, dy: s * 0.3, rx: wingW * 0.48, ry: s * 0.4);

    // Corps fin.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: s * 0.07, height: s * 0.85),
        Radius.circular(s * 0.04),
      ),
      Paint()
        ..color = b.tint.withValues(alpha: (b.opacity * 1.4).clamp(0.0, 1.0)),
    );
  }

  void _wing(Canvas canvas, Paint paint,
      {required double dx,
      required double dy,
      required double rx,
      required double ry}) {
    canvas.drawOval(
      Rect.fromCenter(center: Offset(dx, dy), width: rx * 2, height: ry * 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(_ButterflyPainter old) => old.t != t;
}
