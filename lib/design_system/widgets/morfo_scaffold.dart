import 'package:flutter/material.dart';

import '../morfo_colors.dart';

/// Chrome de page cohérent : fond « void » + halo holo ambiant discret.
class MorfoScaffold extends StatelessWidget {
  const MorfoScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomBar,
    this.floatingActionButton,
    this.glow = true,
    this.safeTop = true,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomBar;
  final Widget? floatingActionButton;
  final bool glow;
  final bool safeTop;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MorfoColors.voidColor,
      extendBodyBehindAppBar: true,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomBar,
      body: Stack(
        children: <Widget>[
          if (glow) const _AmbientGlow(),
          SafeArea(top: safeTop, bottom: false, child: body),
        ],
      ),
    );
  }
}

/// Halo radial holo en haut de l'écran — pose une ambiance sans voler la vedette.
class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -180,
      left: -60,
      right: -60,
      height: 440,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topCenter,
              radius: 0.95,
              colors: <Color>[
                MorfoColors.holoViolet.withValues(alpha: 0.18),
                MorfoColors.holoCyan.withValues(alpha: 0.05),
                Colors.transparent,
              ],
              stops: const <double>[0.0, 0.45, 1.0],
            ),
          ),
        ),
      ),
    );
  }
}
