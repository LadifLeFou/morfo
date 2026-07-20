// Couvre la logique de langue et la retraduction du catalogue.
//
// Ces comportements cassent en silence : l'app compile, les tests d'UI passent,
// et l'utilisateur anglophone se retrouve simplement avec du français.

import 'package:flutter_test/flutter_test.dart';

import 'package:morfo/core/models/morfo_category.dart';
import 'package:morfo/core/models/template.dart';
import 'package:morfo/core/strings.dart';

void main() {
  // Chaque test fixe explicitement la langue : `S` est un état global statique,
  // sans ça l'ordre d'exécution influencerait les résultats.
  tearDown(() => S.apply(AppLanguage.system));

  group('AppLanguage', () {
    test('fromCode reconnaît les codes stockés', () {
      expect(AppLanguage.fromCode('fr'), AppLanguage.french);
      expect(AppLanguage.fromCode('en'), AppLanguage.english);
      expect(AppLanguage.fromCode('system'), AppLanguage.system);
    });

    test('fromCode retombe sur system pour null ou inconnu', () {
      // Cas réels : première installation, ou préférence écrite par une
      // version future de l'app puis relue par une plus ancienne.
      expect(AppLanguage.fromCode(null), AppLanguage.system);
      expect(AppLanguage.fromCode('klingon'), AppLanguage.system);
    });

    test('les langues sont nommées dans leur propre langue', () {
      S.apply(AppLanguage.english);
      expect(AppLanguage.french.label, 'Français');
      expect(AppLanguage.english.label, 'English');
      // Seul « automatique » suit la langue de l'interface.
      expect(AppLanguage.system.label, S.languageSystem);
    });
  });

  group('S.apply', () {
    test('force la langue indépendamment de l’appareil', () {
      S.apply(AppLanguage.french);
      expect(S.isFr, isTrue);
      expect(S.back, 'Retour');

      S.apply(AppLanguage.english);
      expect(S.isFr, isFalse);
      expect(S.back, 'Back');
    });

    test('mémorise le choix tel qu’il a été fait, pas tel qu’il est résolu', () {
      S.apply(AppLanguage.system);
      // `current` doit rester `system` même si l'appareil est français :
      // c'est ce que la feuille de réglages coche.
      expect(S.current, AppLanguage.system);
    });
  });

  group('Catalogue retraduit depuis le backend', () {
    // Le backend ne sert que du français ; l'app retraduit via le template_id.
    const Template gta = Template(
      id: 'gta',
      title: 'GTA V',
      description: 'Style écran de chargement GTA V.',
      category: MorfoCategory.jeux,
    );

    test('en anglais, description traduite localement', () {
      S.apply(AppLanguage.english);
      expect(gta.displayDescription, 'GTA V loading-screen style.');
    });

    test('en français, on garde la valeur du backend', () {
      S.apply(AppLanguage.french);
      expect(gta.displayDescription, 'Style écran de chargement GTA V.');
    });

    test('un style inconnu retombe sur le backend sans planter', () {
      // Scénario réel : un style ajouté côté serveur, absent de la table de
      // cette version de l'app. Il doit s'afficher en français, jamais crasher.
      S.apply(AppLanguage.english);
      const Template futur = Template(
        id: 'style_ajoute_plus_tard',
        title: 'Nouveau style',
        description: 'Description côté serveur.',
        category: MorfoCategory.tendance,
      );
      expect(futur.displayTitle, 'Nouveau style');
      expect(futur.displayDescription, 'Description côté serveur.');
    });

    test('le titre du style star est traduit', () {
      const Template star = Template(
        id: 'selfie_star',
        title: 'Selfie avec une star',
        description: 'peu importe',
        category: MorfoCategory.fun,
      );
      S.apply(AppLanguage.english);
      expect(star.displayTitle, 'Selfie with a star');
      S.apply(AppLanguage.french);
      expect(star.displayTitle, 'Selfie avec une star');
    });
  });

  group('MorfoCategory', () {
    test('la clé d’appairage backend n’est jamais traduite', () {
      // Régression possible : traduire `key` casserait `fromLabel`, et donc le
      // rangement des styles en catégories.
      S.apply(AppLanguage.english);
      expect(MorfoCategory.tendance.key, 'Tendance');
      expect(MorfoCategory.cinema.key, 'Cinéma');
    });

    test('le libellé affiché suit la langue', () {
      S.apply(AppLanguage.english);
      expect(MorfoCategory.tendance.label, 'Trending');
      expect(MorfoCategory.jeux.label, 'Games');

      S.apply(AppLanguage.french);
      expect(MorfoCategory.tendance.label, 'Tendance');
      expect(MorfoCategory.jeux.label, 'Jeux');
    });

    test('fromLabel appaire ce que le backend envoie, quelle que soit la langue',
        () {
      S.apply(AppLanguage.english);
      expect(MorfoCategory.fromLabel('Tendance'), MorfoCategory.tendance);
      expect(MorfoCategory.fromLabel('cinéma'), MorfoCategory.cinema);
      expect(MorfoCategory.fromLabel('jeux'), MorfoCategory.jeux);
    });

    test('une catégorie inconnue ne fait pas disparaître le style', () {
      expect(MorfoCategory.fromLabel('CatégorieInventée'),
          MorfoCategory.tendance);
    });
  });
}
