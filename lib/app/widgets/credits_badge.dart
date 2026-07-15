import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../design_system/design_system.dart';
import '../app_state.dart';

/// Pastille de crédits (chiffres tabulaires) → ouvre la boutique de crédits.
class CreditsBadge extends ConsumerWidget {
  const CreditsBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int credits = ref.watch(creditsProvider);
    return Pressable(
      onTap: () => context.push('/credits'),
      scale: 0.94,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: MorfoColors.surface2.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(Radii.pill),
          border: Border.all(color: MorfoColors.stroke),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.bolt, size: 16, color: MorfoColors.holoWarm),
            const SizedBox(width: 5),
            Text('$credits',
                style: MorfoType.credits.copyWith(fontSize: 15)),
          ],
        ),
      ),
    );
  }
}
