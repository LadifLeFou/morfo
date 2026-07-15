// Test de fumée — vérifie que l'app démarre sur le splash Morfo.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:morfo/core/persistence.dart';
import 'package:morfo/main.dart';

void main() {
  testWidgets('MorfoApp démarre et affiche le logotype', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SharedPreferences sp = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [prefsProvider.overrideWithValue(Prefs(sp))],
        child: const MorfoApp(),
      ),
    );
    await tester.pump();

    expect(find.text('Morfo'), findsOneWidget);
    expect(find.text('GÉNÉRATION PAR IA'), findsOneWidget);

    // Laisse le timer de redirection du splash se déclencher (évite un timer pendant).
    await tester.pump(const Duration(seconds: 3));
  });
}
