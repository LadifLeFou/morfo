import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/haptics.dart';
import '../../../design_system/design_system.dart';
import '../generate_args.dart';
import '../generation_controller.dart';

const List<String> _steps = <String>[
  'Analyse du visage…',
  'Application du style…',
  'Rendu final…',
];

/// Écran de génération — anneau holo, micro-copie rotative, annulation.
class GenerationScreen extends ConsumerStatefulWidget {
  const GenerationScreen({super.key, required this.args});

  final GenerateArgs args;

  @override
  ConsumerState<GenerationScreen> createState() => _GenerationScreenState();
}

class _GenerationScreenState extends ConsumerState<GenerationScreen> {
  Timer? _timer;
  int _step = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
    _timer = Timer.periodic(const Duration(milliseconds: 1600), (_) {
      if (mounted) setState(() => _step = (_step + 1) % _steps.length);
    });
  }

  void _start() {
    ref.read(generationControllerProvider.notifier).run(
          template: widget.args.template,
          bytes: widget.args.bytes,
          sourcePath: widget.args.sourcePath,
        );
  }

  @override
  void dispose() {
    _timer?.cancel();
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
        Haptics.success();
        context.pushReplacement('/result', extra: next.result);
      }
    });

    final GenState state = ref.watch(generationControllerProvider);
    if (state is GenError) return _errorView(state);

    return MorfoScaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const ProgressRingHolo(
              size: 210,
              child: Icon(Icons.auto_awesome,
                  color: MorfoColors.holoPink, size: 30),
            ),
            Gap.h32,
            AnimatedSwitcher(
              duration: Motion.base,
              child: Text(
                _steps[_step],
                key: ValueKey<int>(_step),
                style: MorfoType.titleSmall,
              ),
            ),
            Gap.h8,
            Text('Cela prend quelques secondes', style: MorfoType.caption),
            Gap.h32,
            TextButton(
              onPressed: _cancel,
              child: Text('Annuler', style: MorfoType.label),
            ),
          ],
        ),
      ),
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
                  label: 'Obtenir des crédits',
                  icon: Icons.bolt,
                  onPressed: () => context.push('/credits'),
                )
              else
                GradientButton(
                  label: 'Réessayer',
                  icon: Icons.refresh,
                  onPressed: _start,
                ),
              Gap.h12,
              TextButton(
                onPressed: () => context.pop(),
                child: Text('Retour', style: MorfoType.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
