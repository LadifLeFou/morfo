import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_state.dart';
import '../../../core/strings.dart';
import '../../../design_system/design_system.dart';
import '../../notifications/conversion_notifications.dart';

/// Chemins des vraies photos de démo (avant/après), par id de style.
String _before(String id) => 'assets/images/preview_${id}_before.jpg';
String _after(String id) => 'assets/images/preview_${id}_after.jpg';

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
    _Slide(
      eyebrow: S.onbEyebrow1,
      title: S.onbTitle1,
      body: S.onbBody1,
      visual: BeforeAfterSlider(
        aspectRatio: 1,
        before: Image.asset(_before('renaissance'), fit: BoxFit.cover),
        after: Image.asset(_after('renaissance'), fit: BoxFit.cover),
      ),
    ),
    _Slide(
      eyebrow: S.onbEyebrow2,
      title: S.onbTitle2,
      body: S.onbBody2,
      visual: _StylesPreview(),
    ),
    _Slide(
      eyebrow: S.onbEyebrow3,
      title: S.onbTitle3,
      body: S.onbBody3,
      visual: HoloCard(
        aspectRatio: 1,
        eyebrow: 'Épique',
        title: 'Morfo',
        interactive: true,
        child: Image.asset(_after('blockbuster'), fit: BoxFit.cover),
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
    ref.read(conversionNotificationsProvider).onOnboarded();
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
                child: Text(S.skip, style: MorfoType.label),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (int i) => setState(() => _page = i),
                itemCount: _slides.length,
                itemBuilder: (BuildContext context, int i) {
                  return AnimatedBuilder(
                    animation: _controller,
                    builder: (BuildContext context, Widget? _) {
                      // Position de défilement (delta = distance au centre).
                      double page = _page.toDouble();
                      if (_controller.hasClients &&
                          _controller.position.haveDimensions) {
                        page = _controller.page ?? page;
                      }
                      final double delta = i - page;
                      final double t = (1 - delta.abs()).clamp(0.0, 1.0);
                      final _Slide s = _slides[i];

                      return Opacity(
                        opacity: 0.2 + 0.8 * t,
                        child: Transform.translate(
                          offset: Offset(0, (1 - t) * 22),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxWidth: 360),
                                  child: Transform.translate(
                                    // Parallaxe : le visuel glisse à contre-sens.
                                    offset: Offset(delta * -34, 0),
                                    child: Transform.scale(
                                      scale: 0.9 + 0.1 * t,
                                      child: AspectRatio(
                                        aspectRatio: 1,
                                        child: s.visual,
                                      ),
                                    ),
                                  ),
                                ),
                                Gap.h32,
                                Text(s.eyebrow, style: MorfoType.eyebrow),
                                Gap.h8,
                                Text(
                                  s.title,
                                  textAlign: TextAlign.center,
                                  style: MorfoType.displayMedium,
                                ),
                                Gap.h12,
                                Text(
                                  s.body,
                                  textAlign: TextAlign.center,
                                  style: MorfoType.bodyLarge,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Gap.h24,
            _Dots(count: _slides.length, active: _page),
            Gap.h24,
            GradientButton(
              label: isLast ? S.start : S.next,
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
    // De vrais résultats « après » — donne envie dès l'onboarding.
    const List<(String, String)> items = <(String, String)>[
      ('selfie_star', 'Célébrité'),
      ('golden_hour', 'Golden hour'),
      ('old_money', 'Old money'),
      ('digicam', 'Digicam'),
    ];
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: Gap.md,
      crossAxisSpacing: Gap.md,
      physics: const NeverScrollableScrollPhysics(),
      children: <Widget>[
        for (final (String id, String label) in items)
          _StyleThumb(id: id, label: label),
      ],
    );
  }
}

/// Vignette « après » avec voile bas + label — mini-preview de style.
class _StyleThumb extends StatelessWidget {
  const _StyleThumb({required this.id, required this.label});

  final String id;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: Radii.brMd,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.asset(
            _after(id),
            fit: BoxFit.cover,
            errorBuilder: (BuildContext _, Object _, StackTrace? _) =>
                HoloPlaceholder(seed: id),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(gradient: MorfoColors.scrim),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(Gap.sm),
              child: Text(label, style: MorfoType.eyebrow),
            ),
          ),
        ],
      ),
    );
  }
}
