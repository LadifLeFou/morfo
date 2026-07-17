import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../design_system/design_system.dart';

/// Documents légaux affichés dans l'app.
enum LegalDoc { terms, privacy }

/// Une section de document légal (titre + corps).
class _Section {
  const _Section(this.heading, this.body);
  final String heading;
  final String body;
}

/// Écran légal générique — rend les Conditions ou la Confidentialité.
///
/// ⚠️ Ces textes sont des modèles de départ conformes aux exigences Apple
/// (abonnements auto-renouvelables, confidentialité). Faites-les relire par un
/// professionnel avant publication et remplacez les mentions entre crochets.
class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key, required this.doc});

  final LegalDoc doc;

  static const String _contact = 'support@morfo.app';
  static const String _entity = '[RAISON SOCIALE], éditeur de Morfo';
  static const String _updated = '15 juillet 2026';

  String get _title =>
      doc == LegalDoc.terms ? 'Conditions d’utilisation' : 'Politique de confidentialité';

  List<_Section> get _sections =>
      doc == LegalDoc.terms ? _termsSections : _privacySections;

  @override
  Widget build(BuildContext context) {
    return MorfoScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
          tooltip: 'Retour',
        ),
        title: Text(_title, style: MorfoType.titleMedium),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Gap.xl, Gap.sm, Gap.xl, Gap.giant),
        children: <Widget>[
          Text('Dernière mise à jour : $_updated', style: MorfoType.caption),
          Gap.h24,
          for (final _Section s in _sections) ...<Widget>[
            Text(s.heading, style: MorfoType.titleSmall),
            Gap.h8,
            Text(s.body, style: MorfoType.bodyMedium),
            Gap.h24,
          ],
          Text('Contact : $_contact', style: MorfoType.caption),
          Gap.h8,
          Text(_entity, style: MorfoType.caption),
        ],
      ),
    );
  }

  // — Conditions d'utilisation (EULA) —
  static const List<_Section> _termsSections = <_Section>[
    _Section(
      '1. Acceptation',
      'En téléchargeant ou en utilisant Morfo, vous acceptez les présentes '
          'conditions. Si vous n’êtes pas d’accord, n’utilisez pas l’application.',
    ),
    _Section(
      '2. Licence',
      'Nous vous accordons une licence personnelle, limitée, non exclusive et '
          'non transférable d’utilisation de Morfo sur les appareils que vous '
          'possédez ou contrôlez, conformément aux Règles d’usage de l’App Store '
          'd’Apple.',
    ),
    _Section(
      '3. Abonnements et crédits',
      'Morfo propose des abonnements auto-renouvelables et/ou des crédits. Le '
          'prix et la durée sont affichés dans l’application avant l’achat. Le '
          'paiement est prélevé sur votre compte Apple à la confirmation.',
    ),
    _Section(
      '4. Renouvellement automatique',
      'L’abonnement se renouvelle automatiquement sauf s’il est annulé au moins '
          '24 heures avant la fin de la période en cours. Votre compte est '
          'débité du renouvellement dans les 24 heures précédant la fin de '
          'période. Vous pouvez gérer ou annuler votre abonnement dans les '
          'Réglages de votre compte App Store après l’achat.',
    ),
    _Section(
      '5. Contenu et usage acceptable',
      'Vous êtes responsable des photos que vous importez et devez disposer des '
          'droits nécessaires. Il est interdit d’importer du contenu illégal, '
          'haineux, à caractère sexuel impliquant des mineurs, ou représentant '
          'une personne sans son consentement. Nous pouvons suspendre l’accès en '
          'cas d’abus.',
    ),
    _Section(
      '6. Propriété intellectuelle',
      'Morfo, son logo, son design et ses styles restent notre propriété. Les '
          'images que vous générez à partir de vos propres photos vous '
          'appartiennent, dans les limites du droit applicable.',
    ),
    _Section(
      '7. Absence de garantie',
      'Morfo est fourni « en l’état ». Les transformations par IA peuvent '
          'produire des résultats inattendus. Nous ne garantissons pas '
          'l’exactitude ou l’adéquation à un usage particulier.',
    ),
    _Section(
      '8. Limitation de responsabilité',
      'Dans les limites permises par la loi, notre responsabilité est limitée '
          'au montant que vous avez payé au cours des douze derniers mois.',
    ),
    _Section(
      '9. Modifications',
      'Nous pouvons mettre à jour ces conditions. Les changements importants '
          'vous seront signalés dans l’application.',
    ),
    _Section(
      '10. Droit applicable',
      'Les présentes conditions sont régies par le droit [PAYS/JURIDICTION]. '
          'Tout litige relève des tribunaux compétents de ce ressort.',
    ),
  ];

  // — Politique de confidentialité —
  static const List<_Section> _privacySections = <_Section>[
    _Section(
      '1. Données que nous traitons',
      'Photos que vous importez pour générer une transformation ; informations '
          'd’achat et d’abonnement (via Apple et notre prestataire de facturation) ; '
          'identifiants techniques et données d’usage (type d’appareil, langue, '
          'diagnostics anonymisés).',
    ),
    _Section(
      '2. Finalités',
      'Générer vos transformations, gérer vos abonnements et crédits, assurer '
          'le bon fonctionnement, prévenir la fraude et améliorer l’application.',
    ),
    _Section(
      '3. Traitement des photos',
      'Vos photos sont envoyées à notre service de génération uniquement pour '
          'produire le résultat demandé. Elles ne sont pas vendues ni utilisées '
          'pour de la publicité. Sauf mention contraire, elles ne sont pas '
          'conservées au-delà du traitement nécessaire.',
    ),
    _Section(
      '4. Prestataires tiers',
      'Nous nous appuyons sur des prestataires tels qu’Apple (paiements), '
          'RevenueCat (gestion des abonnements), Superwall (présentation des '
          'offres) et notre fournisseur d’IA (génération d’images). Chacun traite '
          'les données selon sa propre politique.',
    ),
    _Section(
      '5. Conservation',
      'Nous conservons les données de facturation le temps requis par la loi et '
          'les données d’usage pour la durée nécessaire aux finalités ci-dessus.',
    ),
    _Section(
      '6. Vos droits',
      'Vous pouvez demander l’accès, la rectification ou la suppression de vos '
          'données, ainsi que la portabilité, en écrivant à $_contact. '
          'Conformément au RGPD et aux lois applicables.',
    ),
    _Section(
      '7. Enfants',
      'Morfo n’est pas destiné aux enfants de moins de 13 ans (ou de l’âge '
          'minimum requis dans votre pays). Nous ne collectons pas sciemment '
          'leurs données.',
    ),
    _Section(
      '8. Sécurité',
      'Nous mettons en œuvre des mesures raisonnables pour protéger vos '
          'données. Aucune transmission sur Internet n’est toutefois totalement '
          'sûre.',
    ),
    _Section(
      '9. Modifications',
      'Cette politique peut évoluer. Les changements importants seront signalés '
          'dans l’application.',
    ),
  ];
}
