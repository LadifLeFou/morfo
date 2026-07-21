// Produit les captures d'écran App Store en pilotant l'app sur simulateur.
//
// Lancer :
//   flutter drive \
//     --driver=test_driver/integration_test.dart \
//     --target=integration_test/screenshots_test.dart \
//     -d <identifiant-du-simulateur>
//
// Les images atterrissent dans `build/screenshots/`, au format exact du
// simulateur utilisé — prends un iPhone Pro Max pour obtenir le 6,9" exigé
// par Apple.
//
// Rejouable : régénère les captures après n'importe quelle refonte d'interface.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:morfo/main.dart' as app;

void main() {
  final IntegrationTestWidgetsFlutterBinding binding =
      IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  /// Avance de quelques images sans jamais attendre la fin des animations.
  ///
  /// `pumpAndSettle` est inutilisable ici : la nuée de papillons tourne en
  /// boucle infinie, l'app ne « se stabilise » donc jamais.
  Future<void> avancer(WidgetTester tester,
      {int images = 30, int msParImage = 50}) async {
    for (int i = 0; i < images; i++) {
      await tester.pump(Duration(milliseconds: msParImage));
    }
  }

  /// Tape sur le premier widget trouvé, en signalant clairement s'il manque.
  Future<bool> taper(WidgetTester tester, Finder cible, String quoi,
      {bool dernier = false}) async {
    if (cible.evaluate().isEmpty) {
      debugPrint('CAPTURE: « $quoi » introuvable, étape ignorée');
      return false;
    }
    await tester.tap(dernier ? cible.last : cible.first, warnIfMissed: false);
    await avancer(tester);
    return true;
  }

  testWidgets('captures App Store', (WidgetTester tester) async {
    await app.main();
    await avancer(tester, images: 20);

    // Le splash se maintient 2,1 s avant de rediriger.
    await avancer(tester, images: 40, msParImage: 100);

    // 1 — Onboarding : l'avant/après, la capture qui convertit le mieux.
    await binding.takeScreenshot('01_onboarding_avant_apres');

    // Passe l'onboarding.
    await taper(tester, find.text('Skip'), 'Skip');
    await avancer(tester, images: 25);

    // Sur une installation neuve, l'onboarding enchaîne sur le paywall :
    // c'est l'entonnoir de conversion voulu. On le capture au passage, puis
    // on le ferme pour atteindre l'accueil.
    if (find.text('Unlock all of Morfo').evaluate().isNotEmpty) {
      await binding.takeScreenshot('05_abonnement');
      await taper(tester, find.byIcon(Icons.close), 'fermer le paywall');
      await avancer(tester, images: 25);
    }

    // 2 — Accueil : la grille de styles, montre l'étendue du catalogue.
    await binding.takeScreenshot('02_accueil_styles');

    // 3 — Détail d'un style. On passe par la recherche plutôt que par la
    // position dans la grille : l'ordre vient du backend et peut changer.
    final Finder recherche = find.byType(TextField);
    if (recherche.evaluate().isNotEmpty) {
      await tester.enterText(recherche.first, 'Luxe');
      await avancer(tester, images: 25);
    }
    if (await taper(tester, find.text('Luxe'), 'style Luxe', dernier: true)) {
      await avancer(tester, images: 30);
      await binding.takeScreenshot('03_style_luxe');
      await taper(tester, find.byIcon(Icons.arrow_back), 'retour');
      await avancer(tester, images: 20);
    }
    // Vide la recherche, sinon la carte « prompt libre » reste masquée.
    if (recherche.evaluate().isNotEmpty) {
      await tester.enterText(recherche.first, '');
      await avancer(tester, images: 25);
    }

    // 4 — Prompt libre : l'argument différenciant face aux concurrents.
    if (await taper(tester, find.text('Custom prompt'), 'prompt libre')) {
      await avancer(tester, images: 30);
      await binding.takeScreenshot('04_prompt_libre');
      await taper(tester, find.byIcon(Icons.arrow_back), 'retour');
      await avancer(tester, images: 20);
    }

  });
}
