import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_state.dart';
import '../../../core/models/generation_result.dart';
import '../../../design_system/design_system.dart';
import '../../home/template_icon.dart';

/// Historique — grille des générations passées (persistées), état vide invitant.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<GenerationResult> items = ref.watch(historyProvider);

    return MorfoScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Historique'),
      ),
      body: items.isEmpty
          ? _EmptyHistory(onExplore: () => context.go('/home'))
          : GridView.builder(
              padding: const EdgeInsets.fromLTRB(Gap.xl, Gap.sm, Gap.xl, Gap.giant),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: Gap.md,
                crossAxisSpacing: Gap.md,
                childAspectRatio: 0.72,
              ),
              itemCount: items.length,
              itemBuilder: (BuildContext context, int i) =>
                  _HistoryTile(result: items[i]),
            ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.result});
  final GenerationResult result;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: () => context.push('/result', extra: result),
      child: ClipRRect(
        borderRadius: Radii.brMd,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            MorfoImage(
              url: result.outputUrl,
              icon: iconForCategory(result.category),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(gradient: MorfoColors.scrim),
            ),
            Positioned(
              left: Gap.md,
              right: Gap.md,
              bottom: Gap.md,
              child: Text(
                result.templateTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: MorfoType.titleSmall,
              ),
            ),
            if (result.isVideo)
              const Positioned(
                top: Gap.sm,
                right: Gap.sm,
                child: Icon(Icons.play_circle_outline,
                    size: 18, color: MorfoColors.ink),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory({required this.onExplore});
  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Gap.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.auto_awesome_outlined,
                size: 46, color: MorfoColors.muted),
            Gap.h16,
            Text('Tes créations apparaîtront ici',
                style: MorfoType.titleSmall, textAlign: TextAlign.center),
            Gap.h8,
            Text(
              'Choisis un style et lance ta première métamorphose.',
              style: MorfoType.bodyMedium,
              textAlign: TextAlign.center,
            ),
            Gap.h24,
            GradientButton(
              label: 'Explorer les styles',
              icon: Icons.grid_view_rounded,
              expand: false,
              onPressed: onExplore,
            ),
          ],
        ),
      ),
    );
  }
}
