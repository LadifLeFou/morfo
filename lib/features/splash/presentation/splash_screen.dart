import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_state.dart';
import '../../../design_system/design_system.dart';

/// Splash — le logotype se matérialise en gradient holo, puis on redirige.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 2100), () {
      if (!mounted) return;
      final bool onboarded = ref.read(onboardingProvider);
      context.go(onboarded ? '/home' : '/onboarding');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MorfoScaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('GÉNÉRATION PAR IA', style: MorfoType.eyebrow)
                .animate()
                .fadeIn(duration: 700.ms, delay: 400.ms),
            Gap.h12,
            ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (Rect b) =>
                  MorfoColors.holoGradient.createShader(b),
              child: Text(
                'Morfo',
                style: MorfoType.displayLarge
                    .copyWith(fontSize: 88, color: Colors.white),
              ),
            )
                .animate()
                .fadeIn(duration: 700.ms)
                .scale(
                  begin: const Offset(0.85, 0.85),
                  end: const Offset(1, 1),
                  duration: 900.ms,
                  curve: Curves.easeOutBack,
                )
                .shimmer(
                  delay: 500.ms,
                  duration: 1500.ms,
                  color: MorfoColors.ink.withValues(alpha: 0.45),
                ),
          ],
        ),
      ),
    );
  }
}
