import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_state.dart';
import '../../../core/strings.dart';
import '../../../design_system/design_system.dart';
import '../../../services/notification_service.dart';
import '../../../services/purchases_service.dart';
import '../../../services/service_providers.dart';

/// Splash — le logotype se matérialise en gradient holo, puis on redirige.
///
/// Pensée comme une vraie page de chargement : marque centrée dans un halo
/// holo, wordmark spectral, et un indicateur de progression discret en bas.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  static const Duration _hold = Duration(milliseconds: 2100);

  @override
  void initState() {
    super.initState();
    _bootstrap();
    Future<void>.delayed(_hold, () {
      if (!mounted) return;
      final bool onboarded = ref.read(onboardingProvider);
      context.go(onboarded ? '/home' : '/onboarding');
    });
  }

  /// Initialise les achats (no-op en démo ; RevenueCat sur mobile) et
  /// synchronise l'état d'abonnement pendant l'affichage du splash.
  Future<void> _bootstrap() async {
    try {
      await ref.read(purchasesServiceProvider).init();
      await ref.read(subscriptionProvider.notifier).refresh();
      await ref.read(notificationServiceProvider).init();
      // Solde de crédits depuis le serveur (mode réel ; -1 en mock → ignoré).
      final String uid = ref.read(appUserIdProvider);
      final int credits =
          await ref.read(generationServiceProvider).fetchCredits(uid);
      ref.read(creditsProvider.notifier).setBalance(credits);
    } catch (_) {
      // Sans SDK/clé (web, démo), on ignore : l'app reste fonctionnelle.
    }
  }

  @override
  Widget build(BuildContext context) {
    // Respecte « reduce motion » : on fige les animations, on garde l'état final.
    final bool reduce = MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return MorfoScaffold(
      safeTop: false,
      body: Stack(
        children: <Widget>[
          // Nuée de papillons en fond — à peine visible, pour l'ambiance.
          Positioned.fill(child: ButterflyField(reduce: reduce)),

          // Bloc marque, centré.
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _MascotBadge(reduce: reduce),
                Gap.h32,
                _Wordmark(reduce: reduce),
                Gap.h16,
                _tagline(reduce),
              ],
            ),
          ),

          // Indicateur de chargement, ancré en bas.
          Positioned(
            left: 0,
            right: 0,
            bottom: Gap.giant,
            child: _LoadingHint(reduce: reduce),
          ),
        ],
      ),
    );
  }

  Widget _tagline(bool reduce) {
    final Widget text = Text(
      S.tagline,
      style: MorfoType.eyebrow.copyWith(letterSpacing: 3.2),
    );
    if (reduce) return text;
    return text.animate().fadeIn(duration: 700.ms, delay: 700.ms);
  }
}

/// La mascotte posée sur un halo radial holo qui respire doucement.
class _MascotBadge extends StatelessWidget {
  const _MascotBadge({required this.reduce});

  final bool reduce;

  @override
  Widget build(BuildContext context) {
    const double halo = 260;
    const double mascot = 172;

    final Widget stack = SizedBox(
      width: halo,
      height: halo,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          // Halo lumineux derrière la mascotte.
          _buildHalo(halo, reduce),
          // Masque radial : les bords carrés + le cadre néon de l'image se
          // fondent dans le noir, seul le papillon ressort.
          MorfoMascot(size: mascot),
        ],
      ),
    );

    if (reduce) return stack;

    return stack.animate().fadeIn(duration: 600.ms).scale(
          begin: const Offset(0.72, 0.72),
          end: const Offset(1, 1),
          duration: 820.ms,
          curve: Curves.easeOutBack,
        );
  }

  Widget _buildHalo(double size, bool reduce) {
    final Widget glow = DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: <Color>[
            MorfoColors.holoViolet.withValues(alpha: 0.30),
            MorfoColors.holoCyan.withValues(alpha: 0.10),
            Colors.transparent,
          ],
          stops: const <double>[0.0, 0.55, 1.0],
        ),
      ),
      child: SizedBox(width: size, height: size),
    );

    if (reduce) return glow;

    // Respiration lente et infinie du halo.
    return glow
        .animate(onPlay: (AnimationController c) => c.repeat(reverse: true))
        .scale(
          begin: const Offset(0.92, 0.92),
          end: const Offset(1.06, 1.06),
          duration: 2600.ms,
          curve: Curves.easeInOut,
        )
        .fadeIn(begin: 0.75, duration: 2600.ms);
  }
}

/// Le mot « Morfo » peint dans le gradient signature, avec un balayage foil.
class _Wordmark extends StatelessWidget {
  const _Wordmark({required this.reduce});

  final bool reduce;

  @override
  Widget build(BuildContext context) {
    final Widget word = ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (Rect b) => MorfoColors.holoGradient.createShader(b),
      child: Text(
        'Morfo',
        style: MorfoType.displayLarge.copyWith(
          fontSize: 76,
          color: Colors.white,
        ),
      ),
    );

    if (reduce) return word;

    return word
        .animate()
        .fadeIn(duration: 700.ms, delay: 220.ms)
        .scale(
          begin: const Offset(0.86, 0.86),
          end: const Offset(1, 1),
          duration: 900.ms,
          delay: 220.ms,
          curve: Curves.easeOutBack,
        )
        .shimmer(
          delay: 700.ms,
          duration: 1500.ms,
          color: MorfoColors.ink.withValues(alpha: 0.45),
        );
  }
}

/// Anneau holo indéterminé + libellé — signale clairement le chargement.
class _LoadingHint extends StatelessWidget {
  const _LoadingHint({required this.reduce});

  final bool reduce;

  @override
  Widget build(BuildContext context) {
    final Widget hint = Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const ProgressRingHolo(size: 30, strokeWidth: 3),
        Gap.h12,
        Text(S.loading, style: MorfoType.caption),
      ],
    );

    if (reduce) return hint;

    return hint.animate().fadeIn(duration: 600.ms, delay: 900.ms);
  }
}
