import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../morfo_colors.dart';

/// Anneau de progression avec balayage du gradient holo.
///
/// [progress] null → mode indéterminé (arc qui tourne). Sinon 0..1.
class ProgressRingHolo extends StatefulWidget {
  const ProgressRingHolo({
    super.key,
    this.progress,
    this.size = 200,
    this.strokeWidth = 10,
    this.child,
  });

  final double? progress;
  final double size;
  final double strokeWidth;
  final Widget? child;

  @override
  State<ProgressRingHolo> createState() => _ProgressRingHoloState();
}

class _ProgressRingHoloState extends State<ProgressRingHolo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 3))
        ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _c,
        builder: (BuildContext context, Widget? child) {
          return CustomPaint(
            painter: _RingPainter(
              progress: widget.progress,
              rotation: _c.value * 2 * math.pi,
              stroke: widget.strokeWidth,
            ),
            child: child,
          );
        },
        child: Center(child: widget.child),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.rotation,
    required this.stroke,
  });

  final double? progress;
  final double rotation;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double radius = (math.min(size.width, size.height) - stroke) / 2;
    final Rect rect = Rect.fromCircle(center: center, radius: radius);

    final Paint track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = MorfoColors.surface2;
    canvas.drawCircle(center, radius, track);

    final Paint arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: MorfoColors.holoSweep.colors,
        transform: GradientRotation(rotation),
      ).createShader(rect);

    final bool indeterminate = progress == null;
    final double start = -math.pi / 2 + (indeterminate ? rotation : 0);
    final double sweep =
        (indeterminate ? 0.3 : progress!.clamp(0.0, 1.0)) * 2 * math.pi;
    canvas.drawArc(rect, start, sweep, false, arc);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.rotation != rotation;
}
