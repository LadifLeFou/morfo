import 'package:flutter/widgets.dart';

import '../../core/haptics.dart';
import '../morfo_spacing.dart';

/// Enveloppe une cible tactile : press → scale + haptique léger.
///
/// Micro-interaction récurrente de l'app (boutons, cartes, chips).
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.97,
    this.haptic = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final bool haptic;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;
  DateTime? _lastTap;

  /// Anti-rebond : deux taps rapprochés ne déclenchent qu'une action. Protège
  /// toutes les cibles (boutons, cartes) contre la double-navigation et, sur
  /// les actions payantes comme « Générer », le double débit.
  static const Duration _debounce = Duration(milliseconds: 600);

  void _setDown(bool value) {
    if (mounted && _down != value) setState(() => _down = value);
  }

  void _handleTap() {
    final DateTime now = DateTime.now();
    if (_lastTap != null && now.difference(_lastTap!) < _debounce) return;
    _lastTap = now;
    if (widget.haptic) Haptics.light();
    widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    final bool enabled = widget.onTap != null;
    return Semantics(
      button: enabled,
      enabled: enabled,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => _setDown(true) : null,
        onTapUp: enabled ? (_) => _setDown(false) : null,
        onTapCancel: enabled ? () => _setDown(false) : null,
        onTap: enabled ? _handleTap : null,
        child: AnimatedScale(
          scale: _down ? widget.scale : 1.0,
          duration: Motion.fast,
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}
