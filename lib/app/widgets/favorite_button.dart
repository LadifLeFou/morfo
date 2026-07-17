import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/haptics.dart';
import '../../design_system/design_system.dart';
import '../app_state.dart';

/// Bouton cœur — épingle un style dans les favoris (persistés).
class FavoriteButton extends ConsumerWidget {
  const FavoriteButton({super.key, required this.templateId, this.size = 20});

  final String templateId;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool fav =
        ref.watch(favoritesProvider.select((Set<String> s) => s.contains(templateId)));

    return Semantics(
      button: true,
      label: fav ? 'Retirer des favoris' : 'Ajouter aux favoris',
      child: Pressable(
        scale: 0.85,
        onTap: () {
          Haptics.selection();
          ref.read(favoritesProvider.notifier).toggle(templateId);
        },
        child: Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: MorfoColors.voidColor.withValues(alpha: 0.45),
            border: Border.all(color: MorfoColors.stroke),
          ),
          child: AnimatedSwitcher(
            duration: Motion.fast,
            transitionBuilder: (Widget child, Animation<double> a) =>
                ScaleTransition(scale: a, child: child),
            child: Icon(
              fav ? Icons.favorite : Icons.favorite_border,
              key: ValueKey<bool>(fav),
              size: size,
              color: fav ? MorfoColors.holoPink : MorfoColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}
