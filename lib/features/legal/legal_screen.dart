import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/strings.dart';
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
///
/// ⚠️ La version anglaise est une traduction de la version française, qui fait
/// foi. Elle doit elle aussi être relue par un professionnel : une traduction
/// juridique approximative engage l'éditeur au même titre que l'original.
class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key, required this.doc});

  final LegalDoc doc;

  static const String _contact = 'mitrixxaniki94@gmail.com';

  // La LCEN impose d'identifier l'éditeur (nom, adresse) et l'hébergeur.
  //
  // Identité civile et non « Ladi » : la LCEN exige le nom de l'éditeur
  // personne physique, et Apple recoupe avec le compte développeur — dont
  // l'équipe est déjà enregistrée sous « Enes Ayyildiz ».
  //
  // ⚠️ La rue reste à compléter : un code postal seul ne suffit pas.
  static const String _publisherName = 'Enes Ayyildiz';
  static const String _publisherAddress =
      '3 rue Saint-Honoré, 69200 Vénissieux, France';
  static const String _publisherSiret = '[SIRET]';
  static const String _hostName = 'Fly.io, Inc. — 2261 Market Street #4990, '
      'San Francisco, CA 94114, États-Unis';
  static const String _updatedFr = '15 juillet 2026';
  static const String _updatedEn = 'July 15, 2026';

  String get _title => doc == LegalDoc.terms
      ? (S.isFr ? 'Conditions d’utilisation' : 'Terms of Use')
      : (S.isFr ? 'Politique de confidentialité' : 'Privacy Policy');

  List<_Section> get _sections => doc == LegalDoc.terms
      ? (S.isFr ? _termsFr : _termsEn)
      : (S.isFr ? _privacyFr : _privacyEn);

  @override
  Widget build(BuildContext context) {
    return MorfoScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
          tooltip: S.back,
        ),
        title: Text(_title, style: MorfoType.titleMedium),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Gap.xl, Gap.sm, Gap.xl, Gap.giant),
        children: <Widget>[
          Text(S.lastUpdated(S.isFr ? _updatedFr : _updatedEn),
              style: MorfoType.caption),
          Gap.h24,
          for (final _Section s in _sections) ...<Widget>[
            Text(s.heading, style: MorfoType.titleSmall),
            Gap.h8,
            Text(s.body, style: MorfoType.bodyMedium),
            Gap.h24,
          ],
          Text(S.contactLine(_contact), style: MorfoType.caption),
          Gap.h24,
          Text(S.legalNotice.toUpperCase(), style: MorfoType.eyebrow),
          Gap.h8,
          Text(
            '${S.publisher} : $_publisherName\n'
            '$_publisherAddress\n'
            'SIRET : $_publisherSiret\n\n'
            '${S.host} : $_hostName',
            style: MorfoType.caption,
          ),
        ],
      ),
    );
  }

  // — Conditions d'utilisation (EULA) — version française, fait foi —
  static const List<_Section> _termsFr = <_Section>[
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
      'Les présentes conditions sont régies par le droit français. À défaut '
          'de résolution amiable, tout litige relève des tribunaux français '
          'compétents. Conformément au Code de la consommation, vous pouvez '
          'également recourir gratuitement à un médiateur de la consommation.',
    ),
  ];

  // — Terms of Use (EULA) — traduction de la version française —
  static const List<_Section> _termsEn = <_Section>[
    _Section(
      '1. Acceptance',
      'By downloading or using Morfo, you accept these terms. If you do not '
          'agree, do not use the application.',
    ),
    _Section(
      '2. Licence',
      'We grant you a personal, limited, non-exclusive and non-transferable '
          'licence to use Morfo on devices you own or control, in accordance '
          'with Apple’s App Store Usage Rules.',
    ),
    _Section(
      '3. Subscriptions and credits',
      'Morfo offers auto-renewing subscriptions and/or credits. Price and '
          'duration are shown in the app before purchase. Payment is charged to '
          'your Apple account upon confirmation.',
    ),
    _Section(
      '4. Automatic renewal',
      'The subscription renews automatically unless cancelled at least 24 hours '
          'before the end of the current period. Your account is charged for '
          'renewal within the 24 hours before the period ends. You can manage or '
          'cancel your subscription in your App Store account settings after '
          'purchase.',
    ),
    _Section(
      '5. Content and acceptable use',
      'You are responsible for the photos you upload and must hold the '
          'necessary rights. Uploading illegal or hateful content, sexual '
          'content involving minors, or images depicting a person without their '
          'consent is prohibited. We may suspend access in case of abuse.',
    ),
    _Section(
      '6. Intellectual property',
      'Morfo, its logo, design and styles remain our property. Images you '
          'generate from your own photos belong to you, within the limits of '
          'applicable law.',
    ),
    _Section(
      '7. No warranty',
      'Morfo is provided “as is”. AI transformations may produce unexpected '
          'results. We do not warrant accuracy or fitness for any particular '
          'purpose.',
    ),
    _Section(
      '8. Limitation of liability',
      'To the extent permitted by law, our liability is limited to the amount '
          'you paid over the past twelve months.',
    ),
    _Section(
      '9. Changes',
      'We may update these terms. Material changes will be signalled to you in '
          'the application.',
    ),
    _Section(
      '10. Governing law',
      'These terms are governed by French law. Failing an amicable '
          'settlement, any dispute falls under the competent French courts. '
          'Under the French Consumer Code, you may also refer the matter free '
          'of charge to a consumer mediator.',
    ),
  ];

  // — Politique de confidentialité — version française, fait foi —
  static const List<_Section> _privacyFr = <_Section>[
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
          'données, ainsi que la portabilité et la limitation du traitement, en '
          'écrivant à $_contact. Conformément au RGPD. Si notre réponse ne vous '
          'satisfait pas, vous pouvez introduire une réclamation auprès de la '
          'CNIL, autorité française de protection des données (www.cnil.fr).',
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

  // — Privacy Policy — traduction de la version française —
  static const List<_Section> _privacyEn = <_Section>[
    _Section(
      '1. Data we process',
      'Photos you upload to generate a transformation; purchase and '
          'subscription information (via Apple and our billing provider); '
          'technical identifiers and usage data (device type, language, '
          'anonymised diagnostics).',
    ),
    _Section(
      '2. Purposes',
      'To generate your transformations, manage your subscriptions and credits, '
          'keep the service running, prevent fraud and improve the application.',
    ),
    _Section(
      '3. Photo processing',
      'Your photos are sent to our generation service solely to produce the '
          'requested result. They are neither sold nor used for advertising. '
          'Unless stated otherwise, they are not retained beyond the processing '
          'required.',
    ),
    _Section(
      '4. Third-party providers',
      'We rely on providers such as Apple (payments), RevenueCat (subscription '
          'management), Superwall (offer presentation) and our AI provider '
          '(image generation). Each processes data under its own policy.',
    ),
    _Section(
      '5. Retention',
      'We retain billing data for as long as required by law, and usage data '
          'for as long as necessary for the purposes above.',
    ),
    _Section(
      '6. Your rights',
      'You may request access to, correction or deletion of your data, as '
          'well as portability and restriction of processing, by writing to '
          '$_contact. In accordance with the GDPR. If our response does not '
          'satisfy you, you may lodge a complaint with the CNIL, the French '
          'data protection authority (www.cnil.fr).',
    ),
    _Section(
      '7. Children',
      'Morfo is not intended for children under 13 (or the minimum age required '
          'in your country). We do not knowingly collect their data.',
    ),
    _Section(
      '8. Security',
      'We implement reasonable measures to protect your data. However, no '
          'transmission over the Internet is entirely secure.',
    ),
    _Section(
      '9. Changes',
      'This policy may change. Material changes will be signalled in the '
          'application.',
    ),
  ];
}
