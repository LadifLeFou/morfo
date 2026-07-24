import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_state.dart';
import '../../../core/haptics.dart';
import '../../../core/strings.dart';
import '../../../design_system/design_system.dart';
import '../../notifications/conversion_notifications.dart';
import '../generate_args.dart';
import '../generation_controller.dart';

/// Écran de génération — anneau holo avec pourcentage, micro-copie, annulation.
class GenerationScreen extends ConsumerStatefulWidget {
  const GenerationScreen({super.key, required this.args});

  final GenerateArgs args;

  @override
  ConsumerState<GenerationScreen> createState() => _GenerationScreenState();
}

class _GenerationScreenState extends ConsumerState<GenerationScreen>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  int _step = 0;
  late final AnimationController _progress;

  /// L'utilisateur était-il déjà abonné en entrant sur l'écran ?
  /// Non → on joue l'aperçu de génération puis on présente le paywall.
  late final bool _subscribed = ref.read(subscriptionProvider);

  @override
  void initState() {
    super.initState();

    if (_subscribed) {
      // Abonné : vraie génération. Progression qui monte puis ralentit à ~97 %
      // jusqu'à ce que le résultat arrive (GenDone).
      _progress = AnimationController(
        vsync: this,
        duration: Duration(seconds: widget.args.template.isVideo ? 110 : 30),
      )..forward();
      WidgetsBinding.instance.addPostFrameCallback((_) => _start());
    } else {
      // Non abonné : aperçu convaincant qui va jusqu'à 100 %, puis paywall.
      _progress = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 4200),
      );
      _progress.forward().whenComplete(_goPaywall);
    }

    _timer = Timer.periodic(const Duration(milliseconds: 1800), (_) {
      if (mounted) setState(() => _step = (_step + 1) % 3);
    });
  }

  /// Fin de l'aperçu (utilisateur non abonné) → écran d'abonnement, en
  /// transmettant les arguments pour reprendre la génération après paiement.
  void _goPaywall() {
    if (!mounted) return;
    Haptics.success();
    // Intention forte : il a « généré » mais doit payer. On programme les
    // relances de reconquête (annulées s'il souscrit).
    ref
        .read(conversionNotificationsProvider)
        .onGenerationAbandoned(widget.args.template.displayTitle);
    context.pushReplacement('/paywall', extra: widget.args);
  }

  void _start() {
    ref.read(generationControllerProvider.notifier).run(
          template: widget.args.template,
          bytes: widget.args.bytes,
          sourcePath: widget.args.sourcePath,
          customPrompt: widget.args.customPrompt,
        );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progress.dispose();
    super.dispose();
  }

  void _cancel() {
    ref.read(generationControllerProvider.notifier).cancel();
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<GenState>(generationControllerProvider,
        (GenState? _, GenState next) {
      if (next is GenDone) {
        _progress.stop();
        Haptics.success();
        context.pushReplacement('/result', extra: next.result);
      }
    });

    final GenState state = ref.watch(generationControllerProvider);
    if (state is GenError) return _errorView(state);

    // Respecte « reduce motion » : on fige la scène, on garde la composition.
    final bool reduce = MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return MorfoScaffold(
      body: Stack(
        children: <Widget>[
          // Fond vivant : la nuée de papillons, bien plus présente qu'au
          // splash, occupe le regard pendant toute l'attente.
          Positioned.fill(
            child: ButterflyField(
              reduce: reduce,
              count: 16,
              intensity: 3.6,
              cycle: const Duration(seconds: 18),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    // Mascotte en filigrane, derrière l'anneau de progression.
                    _mascot(reduce),
                    AnimatedBuilder(
                      animation: _progress,
                      builder: (BuildContext context, Widget? _) {
                        // Abonné : on plafonne à 97 % jusqu'au vrai résultat.
                        // Aperçu : on laisse filer jusqu'à 100 %.
                        final double cap = _subscribed ? 0.97 : 1.0;
                        final double p =
                            Curves.easeOut.transform(_progress.value) * cap;
                        return ProgressRingHolo(
                          progress: p,
                          size: 210,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text('${(p * 100).round()}',
                                  style: MorfoType.displayLarge),
                              Text('%', style: MorfoType.caption),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
                Gap.h32,
                AnimatedSwitcher(
                  duration: Motion.base,
                  child: Text(
                    widget.args.template.isVideo
                        ? S.genVideo
                        : S.genSteps[_step],
                    key: ValueKey<int>(
                        widget.args.template.isVideo ? -1 : _step),
                    style: MorfoType.titleSmall,
                  ),
                ),
                Gap.h8,
                Text(
                  widget.args.template.isVideo
                      ? S.genWaitVideo
                      : S.genWaitImage,
                  style: MorfoType.caption,
                ),
                Gap.h32,
                TextButton(
                  onPressed: _cancel,
                  child: Text(S.cancel, style: MorfoType.label),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Mascotte en filigrane derrière l'anneau, posée sur un halo qui respire.
  Widget _mascot(bool reduce) {
    const double halo = 250;

    final Widget stack = SizedBox(
      width: halo,
      height: halo,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: <Color>[
                  MorfoColors.holoViolet.withValues(alpha: 0.26),
                  MorfoColors.holoCyan.withValues(alpha: 0.08),
                  Colors.transparent,
                ],
                stops: const <double>[0.0, 0.55, 1.0],
              ),
            ),
            child: const SizedBox(width: halo, height: halo),
          ),
          // Discrète : l'anneau et le pourcentage restent l'information
          // principale, la mascotte n'est qu'une signature de marque.
          const MorfoMascot(size: 168, opacity: 0.22),
        ],
      ),
    );

    if (reduce) return stack;

    return stack
        .animate(onPlay: (AnimationController c) => c.repeat(reverse: true))
        .scale(
          begin: const Offset(0.94, 0.94),
          end: const Offset(1.06, 1.06),
          duration: 2600.ms,
          curve: Curves.easeInOut,
        );
  }

  Widget _errorView(GenError state) {
    return MorfoScaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(Gap.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.error_outline,
                  size: 44, color: MorfoColors.danger),
              Gap.h16,
              Text(state.message,
                  textAlign: TextAlign.center, style: MorfoType.titleSmall),
              Gap.h32,
              if (state.insufficientCredits)
                GradientButton(
                  label: S.getCredits,
                  icon: Icons.bolt,
                  onPressed: () => context.push('/credits'),
                )
              else
                GradientButton(
                  label: S.retry,
                  icon: Icons.refresh,
                  onPressed: _start,
                ),
              Gap.h12,
              TextButton(
                onPressed: () => context.pop(),
                child: Text(S.back, style: MorfoType.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
