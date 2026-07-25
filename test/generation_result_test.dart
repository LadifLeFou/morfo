// Verrouille la sérialisation de l'historique : une création qui fait un
// aller-retour JSON doit revenir identique, quelle que soit la langue.

import 'package:flutter_test/flutter_test.dart';

import 'package:morfo/core/models/generation_result.dart';
import 'package:morfo/core/models/morfo_category.dart';
import 'package:morfo/core/models/template.dart';
import 'package:morfo/core/strings.dart';

void main() {
  tearDown(() => S.apply(AppLanguage.system));

  GenerationResult sample(MorfoCategory cat) => GenerationResult(
        id: 'abc',
        templateId: 'gta',
        templateTitle: 'GTA V',
        category: cat,
        outputUrl: 'https://morfo-backend/image?u=x',
        kind: TemplateKind.image,
        createdAt: DateTime.fromMillisecondsSinceEpoch(1700000000000),
      );

  test('la catégorie survit à l’aller-retour, même générée en anglais', () {
    // Bug corrigé : toJson stockait le libellé traduit (« Games »), que
    // fromLabel ne savait pas relire → toute création non-Tendance retombait
    // sur Tendance.
    S.apply(AppLanguage.english);
    for (final MorfoCategory cat in MorfoCategory.values) {
      final GenerationResult back =
          GenerationResult.fromJson(sample(cat).toJson());
      expect(back.category, cat, reason: 'catégorie $cat perdue au reload');
    }
  });

  test('displayUrl préfère la copie locale quand elle existe', () {
    final GenerationResult sansLocal = sample(MorfoCategory.jeux);
    expect(sansLocal.displayUrl, sansLocal.outputUrl);

    final GenerationResult avecLocal =
        sansLocal.copyWith(localPath: '/var/morfo_results/abc.jpg');
    expect(avecLocal.displayUrl, '/var/morfo_results/abc.jpg');
  });

  test('localPath survit à l’aller-retour JSON', () {
    final GenerationResult r =
        sample(MorfoCategory.tendance).copyWith(localPath: '/tmp/abc.jpg');
    expect(GenerationResult.fromJson(r.toJson()).localPath, '/tmp/abc.jpg');
  });

  test('un ancien JSON sans local_path se recharge sans erreur', () {
    final Map<String, dynamic> vieux = sample(MorfoCategory.fun).toJson()
      ..remove('local_path');
    expect(GenerationResult.fromJson(vieux).localPath, isNull);
  });
}
