import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/design_system.dart';
import '../../../app/app_state.dart';

class _Slide {
  const _Slide({
    required this.eyebrow,
    required this.title,
    required this.body,
    required this.visual,
  });
  final String eyebrow;
  final String title;
  final String body;
  final Widget visual;
}

/// Onboarding — 3 slides, value prop + avant/après, dernier slide → paywall.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  late final List<_Slide> _slides = <_Slide>[
    const _Slide(
      eyebrow: 'Avant · Après',
      title: 'Transforme tes photos\nen métamorphoses',
      body: 'Un portrait, un style, une révélation. Glisse pour comparer.',
      visual: BeforeAfterSlider(
        aspectRatio: 1,
        before: HoloPlaceholder(seed: 'onb_avant', icon: Icons.person_outline),
        after: HoloPlaceholder(seed: 'onb_epic', icon: Icons.shield_moon_outlined),
      ),
    ),
    _Slide(
      eyebrow: 'Des dizaines de styles',
      title: 'Épique, rétro, fun,\ncinéma…',
      body: 'Choisis un style, importe une photo, laisse Morfo opérer.',
      visual: _StylesPreview(),
    ),
    const _Slide(
      eyebrow: 'Ta carte à collectionner',
      title: 'Un résultat que tu\nauras envie de partager',
      body: 'Chaque rendu devient une carte holographique unique.',
      visual: HoloCard(
        aspectRatio: 1,
        eyebrow: 'Guerrier épique',
        title: 'Ton résultat',
        interactive: true,
        child: HoloPlaceholder(seed: 'onb_card', icon: Icons.auto_awesome),
      ),
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _finish() {
    ref.read(onboardingProvider.notifier).complete();
    context.go('/paywall');
  }

  void _next() {
    if (_page >= _slides.length - 1) {
      _finish();
    } else {
      _controller.nextPage(duration: Motion.base, curve: Curves.easeOutCubic);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLast = _page == _slides.length - 1;
    return MorfoScaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Gap.xl),
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finish,
                child: Text('Passer', style: MorfoType.label),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (int i) => setState(() => _page = i),
                itemCount: _slides.length,
                itemBuilder: (BuildContext context, int i) {
                  final _Slide s = _slides[i];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      AspectRatio(aspectRatio: 1, child: s.visual),
                      Gap.h32,
                      Text(s.eyebrow, style: MorfoType.eyebrow),
                      Gap.h8,
                      Text(s.title, style: MorfoType.displayMedium),
                      Gap.h12,
                      Text(s.body, style: MorfoType.bodyLarge),
                    ],
                  );
                },
              ),
            ),
            Gap.h24,
            _Dots(count: _slides.length, active: _page),
            Gap.h24,
            GradientButton(
              label: isLast ? 'Commencer' : 'Suivant',
              icon: isLast ? Icons.auto_awesome : null,
              onPressed: _next,
            ),
            Gap.h32,
          ],
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.active});
  final int count;
  final int active;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(count, (int i) {
        final bool on = i == active;
        return AnimatedContainer(
          duration: Motion.fast,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: on ? 26 : 8,
          height: 8,
          decoration: BoxDecoration(
            gradient: on ? MorfoColors.holoGradient : null,
            color: on ? null : MorfoColors.stroke,
            borderRadius: BorderRadius.circular(Radii.pill),
          ),
        );
      }),
    );
  }
}

class _StylesPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const List<(String, IconData)> items = <(String, IconData)>[
      ('cyberpunk', Icons.bolt_outlined),
      ('anime', Icons.brush_outlined),
      ('golden_hour', Icons.wb_twilight),
      ('film_noir', Icons.movie_outlined),
    ];
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: Gap.md,
      crossAxisSpacing: Gap.md,
      physics: const NeverScrollableScrollPhysics(),
      children: <Widget>[
        for (final (String seed, IconData icon) in items)
          ClipRRect(
            borderRadius: Radii.brMd,
            child: HoloPlaceholder(seed: seed, icon: icon),
          ),
      ],
    );
  }
}
