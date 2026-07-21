import 'dart:ui';

import 'models/morfo_category.dart';

/// Langue de l'interface choisie par l'utilisateur.
///
/// [system] suit la langue de l'appareil ; les autres la forcent.
enum AppLanguage {
  system('system'),
  french('fr'),
  english('en');

  const AppLanguage(this.code);

  /// Code stocké dans les préférences.
  final String code;

  /// Libellé affiché dans les réglages. Les langues sont nommées dans leur
  /// propre langue (convention iOS), seul « automatique » est traduit.
  String get label => switch (this) {
        AppLanguage.system => S.languageSystem,
        AppLanguage.french => 'Français',
        AppLanguage.english => 'English',
      };

  static AppLanguage fromCode(String? code) => AppLanguage.values.firstWhere(
        (AppLanguage l) => l.code == code,
        orElse: () => AppLanguage.system,
      );
}

/// Localisation légère — suit la langue de l'appareil ou le choix utilisateur.
///
/// FR si l'appareil est en français, sinon anglais (défaut international).
/// Extensible à d'autres langues en ajoutant des branches.
class S {
  static bool _fr = false;
  static AppLanguage _current = AppLanguage.system;

  /// À appeler au démarrage (avant runApp).
  static void init() => apply(AppLanguage.system);

  /// Langue actuellement appliquée (telle que choisie, pas résolue).
  static AppLanguage get current => _current;

  /// Applique une préférence de langue. [AppLanguage.system] retombe sur la
  /// langue de l'appareil. Les écrans lisant `S` doivent être reconstruits
  /// après l'appel (voir `languageProvider`).
  static void apply(AppLanguage language) {
    _current = language;
    _fr = switch (language) {
      AppLanguage.french => true,
      AppLanguage.english => false,
      AppLanguage.system => _deviceIsFrench,
    };
  }

  static bool get _deviceIsFrench =>
      PlatformDispatcher.instance.locale.languageCode.toLowerCase() == 'fr';

  static bool get isFr => _fr;
  static String _(String fr, String en) => _fr ? fr : en;

  // — Commun —
  static String get generate => _('Générer', 'Generate');
  static String get retry => _('Réessayer', 'Try again');
  static String get back => _('Retour', 'Back');
  static String get cancel => _('Annuler', 'Cancel');
  static String get save => _('Enregistrer', 'Save');
  static String get share => _('Partager', 'Share');
  static String get regenerate => _('Regénérer', 'Regenerate');
  static String get restore => _('Restaurer les achats', 'Restore purchases');
  static String get terms => _('Conditions', 'Terms');
  static String get privacy => _('Confidentialité', 'Privacy');
  static String get insufficientCredits => _('Crédits insuffisants.', 'Not enough credits.');
  static String get genFailed => _('La génération a échoué. Réessaie.', 'Generation failed. Try again.');
  static String get getCredits => _('Obtenir des crédits', 'Get credits');

  // — Splash —
  static String get tagline => _('GÉNÉRATION PAR IA', 'AI GENERATION');
  static String get loading => _('Chargement…', 'Loading…');

  // — Onboarding —
  static String get skip => _('Passer', 'Skip');
  static String get next => _('Suivant', 'Next');
  static String get start => _('Commencer', 'Start');
  static String get onbTitle1 => _('Transforme tes photos\nen métamorphoses', 'Transform your photos\ninto metamorphoses');
  static String get onbBody1 => _('Un portrait, un style, une révélation. Glisse pour comparer.', 'A portrait, a style, a reveal. Slide to compare.');
  static String get onbEyebrow1 => _('Avant · Après', 'Before · After');
  static String get onbTitle2 => _('Des dizaines de styles\ntendance', 'Dozens of trending\nstyles');
  static String get onbBody2 => _('Choisis un style, importe une photo, laisse Morfo opérer.', 'Pick a style, upload a photo, let Morfo work.');
  static String get onbEyebrow2 => _('Des styles tendance', 'Trending styles');
  static String get onbTitle3 => _('Un résultat que tu\nauras envie de partager', 'A result you\'ll\nwant to share');
  static String get onbBody3 => _('Chaque rendu devient une carte holographique unique.', 'Every result becomes a unique holographic card.');
  static String get onbEyebrow3 => _('Ta carte à collectionner', 'Your collectible card');

  // — Home —
  static String get searchHint => _('Rechercher un style', 'Search a style');
  static String get all => _('Tout', 'All');
  static String get customPrompt => _('Prompt libre', 'Custom prompt');
  static String get customPromptSub => _('Écris ta propre transformation', 'Write your own transformation');
  static String get noStyleMatch => _('Aucun style ne correspond.', 'No style matches.');
  static String get loadStylesError => _('Impossible de charger les styles.', 'Could not load styles.');
  static String featured(String cat) => _('À la une · $cat', 'Featured · $cat');
  static String get video => _('Vidéo', 'Video');

  /// Libellé d'une catégorie — délègue à l'enum, source unique de vérité.
  static String category(MorfoCategory c) => c.label;

  // — Génération —
  static String get genStep1 => _('Analyse du visage…', 'Analyzing face…');
  static String get genStep2 => _('Application du style…', 'Applying style…');
  static String get genStep3 => _('Rendu final…', 'Final render…');
  static List<String> get genSteps => <String>[genStep1, genStep2, genStep3];
  static String get genVideo => _('Création de ta vidéo…', 'Creating your video…');
  static String get genWaitImage => _('Cela prend quelques secondes', 'This takes a few seconds');
  static String get genWaitVideo => _('La vidéo prend 1 à 2 minutes', 'Video takes 1 to 2 minutes');
  static String get contentBlocked => _(
        'Cette demande a été bloquée par le filtre de sécurité. Reformule ta demande ou essaie une autre photo.',
        'This request was blocked by the safety filter. Rephrase it or try another photo.',
      );
  static String get noFace => _('Aucun visage détecté. Utilise une photo de face, nette et bien éclairée.', 'No face detected. Use a clear, well-lit, front-facing photo.');

  // — Résultat —
  static String get yourResult => _('Ton résultat', 'Your result');
  static String get yourCard => _('Ta carte', 'Your card');
  static String get beforeAfter => _('Avant / Après', 'Before / After');
  static String get tryAnotherStyle => _('Essayer un autre style', 'Try another style');
  static String get savedToGallery => _('Enregistré dans ta galerie.', 'Saved to your gallery.');
  static String get saved => _('Enregistré', 'Saved');
  static String get saving => _('Enregistrement…', 'Saving…');
  static String get saveFailed =>
      _('Enregistrement impossible. Réessaie.', 'Could not save. Try again.');
  static String get savePermissionDenied => _(
        'Autorise l’accès à tes photos dans Réglages pour enregistrer.',
        'Allow photo access in Settings to save.',
      );
  static String get saveUnsupported => _(
        'Utilise le partage pour télécharger l’image.',
        'Use share to download the image.',
      );
  static String get shareUnavailable => _('Partage indisponible.', 'Sharing unavailable.');
  static String shareText(String t) => _('Ma métamorphose « $t » avec Morfo ✨', 'My « $t » metamorphosis with Morfo ✨');

  // — Commun (suite) —
  static String get close => _('Fermer', 'Close');
  static String get delete => _('Supprimer', 'Delete');
  static String get clear => _('Effacer', 'Clear');
  static String get history => _('Historique', 'History');
  static String get favorites => _('Favoris', 'Favorites');
  static String get credits => _('Crédits', 'Credits');

  // — Catégories —
  static String get catTrending => _('Tendance', 'Trending');
  static String get catAesthetic => _('Aesthetic', 'Aesthetic');
  static String get catFun => _('Fun', 'Fun');
  static String get catGames => _('Jeux', 'Games');
  static String get catCinema => _('Cinéma', 'Cinema');

  // — Avant / Après —
  static String get before => _('AVANT', 'BEFORE');
  static String get after => _('APRÈS', 'AFTER');

  // — Détail d'un style —
  static String get tryThisStyle => _('Essayer ce style', 'Try this style');

  // — Import photo —
  static String get yourPhoto => _('Ta photo', 'Your photo');
  static String get chosenStyle => _('Style choisi', 'Chosen style');
  static String get fromGallery => _('Depuis la galerie', 'From gallery');
  static String get takePhoto => _('Prendre une photo', 'Take a photo');
  static String get preparingPhoto =>
      _('Préparation de la photo…', 'Preparing photo…');
  static String get chooseAnotherPhoto =>
      _('Choisir une autre photo', 'Choose another photo');
  static String get photoAccessError => _(
        'Accès à la photo impossible. Vérifie les autorisations.',
        'Could not access the photo. Check your permissions.',
      );
  static String generateFor(int cost) => _(
        'Générer · $cost crédit${cost > 1 ? 's' : ''}',
        'Generate · $cost credit${cost > 1 ? 's' : ''}',
      );

  // — Style « selfie avec une star » —
  static String get whichStar => _('QUELLE STAR ?', 'WHICH STAR?');
  static String get whichStarHint => _(
        'Ex : à côté de Lionel Messi, sur le terrain, il passe le bras autour de mon épaule…',
        'E.g. next to Lionel Messi, on the pitch, his arm around my shoulder…',
      );
  static String get whichStarHelp => _(
        'Décris uniquement la star (qui, où, la pose). Les autres demandes sont ignorées.',
        'Describe only the star (who, where, the pose). Anything else is ignored.',
      );
  static String get describeStarFirst =>
      _('Décris d’abord la star ci-dessus.', 'Describe the star above first.');

  // — Prompt libre —
  static String get ideas => _('IDÉES', 'IDEAS');
  static String get importPhoto => _('Importe une photo', 'Import a photo');
  static String get changePhoto => _('Changer la photo', 'Change photo');
  static String get videoNote => _(
        'La vidéo dure ~5 s et prend un peu plus de temps à générer.',
        'The video lasts ~5 s and takes a bit longer to generate.',
      );

  // — Historique —
  static String get clearAll => _('Tout effacer', 'Clear all');
  static String get clearAllTitle => _('Tout effacer ?', 'Clear everything?');
  static String get clearAllBody => _(
        'Toutes tes créations seront retirées de l’historique. Cette action est définitive.',
        'All your creations will be removed from your history. This cannot be undone.',
      );
  static String get deleteOneTitle =>
      _('Supprimer cette création ?', 'Delete this creation?');
  static String get deleteOneBody => _(
        'Elle disparaîtra de ton historique.',
        'It will disappear from your history.',
      );
  static String get emptyHistory => _(
        'Tes créations apparaîtront ici',
        'Your creations will appear here',
      );
  static String get emptyHistoryCta => _(
        'Choisis un style et lance ta première métamorphose.',
        'Pick a style and start your first metamorphosis.',
      );
  static String get exploreStyles => _('Explorer les styles', 'Explore styles');
  static String get favoritesEmptyHint => _(
        'Touche le cœur sur un style pour le retrouver ici.',
        'Tap the heart on a style to find it here.',
      );

  // — Crédits —
  static String get recharge => _('Recharger', 'Top up');
  static String get packsUnavailable =>
      _('Packs indisponibles.', 'Packs unavailable.');
  static String get yourBalance => _('Ton solde', 'Your balance');
  static String get creditsAvailable =>
      _('crédits disponibles', 'credits available');
  static String creditsAdded(int n) =>
      _('$n crédits ajoutés.', '$n credits added.');

  // — Paywall / abonnement —
  static String get unlockAll =>
      _('Débloque tout Morfo', 'Unlock all of Morfo');
  static String get creditsPerWeek =>
      _('650 crédits / semaine', '650 credits / week');
  static String get purchasesRestored =>
      _('Achats restaurés.', 'Purchases restored.');
  static String get noPurchasesToRestore =>
      _('Aucun achat à restaurer.', 'No purchases to restore.');
  static String trialThenPrice(int days, String price) => _(
        '$days jours gratuits, puis $price',
        '$days days free, then $price',
      );
  static String get planWeekly => _('Hebdomadaire', 'Weekly');
  static String get planYearly => _('Annuel', 'Yearly');
  static String get planYearlySub => _(
        'soit 1,92 €/semaine — économise 52 %',
        'that’s €1.92/week — save 52%',
      );
  static String creditsPack(int n) => _('$n crédits', '$n credits');

  // Prix de démonstration. En production, l'App Store fournit des montants
  // déjà localisés via RevenueCat — ces valeurs ne servent que de repli.
  static String get priceWeekly => _('3,99 €', '€3.99');
  static String get priceAnnual => _('99,99 €', '€99.99');
  static String get pricePack100 => _('2,99 €', '€2.99');
  static String get pricePack300 => _('6,99 €', '€6.99');
  static String get pricePack1000 => _('19,99 €', '€19.99');

  // — Génération (suite) —
  static String get genCancelled =>
      _('Génération annulée.', 'Generation cancelled.');

  // — Réglages —
  static String get settings => _('Réglages', 'Settings');
  static String get subscription => _('Abonnement', 'Subscription');
  static String get preferences => _('Préférences', 'Preferences');
  static String get about => _('À propos', 'About');
  static String get subActive =>
      _('Abonnement actif', 'Subscription active');
  static String get thanksSupport =>
      _('Merci de soutenir Morfo.', 'Thanks for supporting Morfo.');
  static String get subscribe => _('S’abonner', 'Subscribe');
  static String get subPitch => _(
        '3,99 €/sem · 650 crédits chaque semaine.',
        '€3.99/wk · 650 credits every week.',
      );
  static String get termsOfUse =>
      _('Conditions d’utilisation', 'Terms of use');
  static String get contact => _('Contact', 'Contact');
  static String contactUs(String email) =>
      _('Écris-nous à $email', 'Email us at $email');
  static String get language => _('Langue', 'Language');
  static String get languageSystem =>
      _('Automatique (appareil)', 'Automatic (device)');
  static String get chooseLanguage =>
      _('Choisir la langue', 'Choose language');

  // — Prompt libre (suite) —
  static String get photo => _('Photo', 'Photo');
  static String get galleryShort => _('Galerie', 'Gallery');
  static String get cameraShort => _('Caméra', 'Camera');
  static String get photoAccessErrorShort =>
      _('Accès à la photo impossible.', 'Could not access the photo.');
  static String get freePromptIntro => _(
        'Importe ta photo, choisis Photo ou Vidéo, et décris ce que tu veux.',
        'Import your photo, pick Photo or Video, and describe what you want.',
      );
  static String get freePromptHintVideo => _(
        'Ex : il sourit et fait un clin d’œil, la caméra zoome…',
        'E.g. he smiles and winks, the camera zooms in…',
      );
  static String get freePromptHintImage => _(
        'Ex : en astronaute dans l’espace, cinématographique…',
        'E.g. as an astronaut in space, cinematic…',
      );
  static String generateVideoFor(int cost) => _(
        'Générer la vidéo · $cost crédits',
        'Generate video · $cost credits',
      );

  /// Idées de prompt proposées sous le champ de saisie.
  static List<String> get promptSuggestions => _fr
      ? const <String>[
          'en astronaute dans l’espace',
          'en personnage cyberpunk néon',
          'portrait renaissance à l’huile',
          'en super-héros de comics',
          'en roi médiéval, cinématographique',
          'style vieux film argentique',
        ]
      : const <String>[
          'as an astronaut in space',
          'as a neon cyberpunk character',
          'renaissance oil portrait',
          'as a comic-book superhero',
          'as a medieval king, cinematic',
          'old film-stock look',
        ];

  // — Paywall (suite) —
  static String get lockedPreview =>
      _('APERÇU VERROUILLÉ', 'LOCKED PREVIEW');
  static String get unlockYourResult => _(
        'Abonne-toi pour révéler ton résultat',
        'Subscribe to reveal your result',
      );
  static String get livePortrait => _('Portrait vivant', 'Live portrait');
  static String get offersUnavailable => _(
        'Offres indisponibles pour le moment.',
        'Offers unavailable right now.',
      );
  static String get continueLabel => _('Continuer', 'Continue');
  static String get popular => _('POPULAIRE', 'POPULAR');
  static String startTrial(int days) => _(
        'Commencer mes $days jours gratuits',
        'Start my $days free days',
      );
  static String freeDaysBadge(int days) =>
      _('$days JOURS GRATUITS', '$days FREE DAYS');
  static String trialTerms(int days, String price) => _(
        'Gratuit pendant $days jours, puis $price. Annule quand tu veux, sans frais.',
        'Free for $days days, then $price. Cancel anytime, no charge.',
      );
  static String get autoRenewNotice => _(
        'Abonnement à renouvellement automatique. Le paiement est prélevé sur '
            'ton compte Apple à la confirmation. Il se renouvelle sauf annulation '
            'au moins 24 h avant la fin de la période ; gère-le à tout moment '
            'dans les Réglages de ton compte App Store.',
        'Auto-renewing subscription. Payment is charged to your Apple account '
            'at confirmation. It renews unless cancelled at least 24 h before '
            'the end of the period; manage it anytime in your App Store account '
            'settings.',
      );

  /// Avantages listés sur le paywall.
  static List<String> get paywallPerks => _fr
      ? const <String>[
          '650 crédits rechargés chaque semaine',
          'Tous les styles, sans filigrane',
          'Photos et vidéos par IA',
          'Rendus en haute résolution',
        ]
      : const <String>[
          '650 credits topped up every week',
          'Every style, no watermark',
          'AI photos and videos',
          'High-resolution renders',
        ];

  // — Onboarding (suite) —
  static String get epic => _('Épique', 'Epic');
  static String get celebrity => _('Célébrité', 'Celebrity');

  // — Catalogue de styles —
  //
  // En mode réel, titres et descriptions arrivent du backend **en français**.
  // On les retraduit ici à partir du `template_id`, qui lui est stable. Un id
  // inconnu (nouveau style côté serveur) retombe sur la valeur du backend.

  static const Map<String, String> _titlesEn = <String, String>{
    'selfie_star': 'Selfie with a star',
  };

  static const Map<String, String> _descriptionsEn = <String, String>{
    'yearbook': 'American class photo, unapologetic retro grain.',
    'flash_wedding': 'Warm flash-lit wedding portrait.',
    'linkedin': 'Professional headshot, business attire.',
    'digicam': '2000s point-and-shoot flash, party vibe.',
    'macbook_selfie': 'Photo Booth webcam selfie.',
    'old_money': 'Timeless elegance, quiet luxury.',
    'golden_hour': 'Golden end-of-day light.',
    'prom': 'Prom night photo, formal wear.',
    'selfie_star':
        'A selfie with the celebrity of your choice: describe them, we handle the rest.',
    'luxe': 'Luxury cars, money and penthouse — the dream life.',
    'gta': 'GTA V loading-screen style.',
    'minecraft': 'Minecraft character and world.',
    'renaissance': 'Classic oil-painting portrait.',
    'blockbuster': 'Hollywood movie poster.',
  };

  /// Titre d'un style, traduit si connu — sinon la valeur du backend.
  static String templateTitle(String id, String fallback) =>
      _fr ? fallback : (_titlesEn[id] ?? fallback);

  /// Description d'un style, traduite si connue — sinon celle du backend.
  static String templateDescription(String id, String fallback) =>
      _fr ? fallback : (_descriptionsEn[id] ?? fallback);

  // — Légal / erreurs techniques —
  static String get videoTrackingLost => _(
        'Le suivi de la vidéo a été interrompu.',
        'Video tracking was interrupted.',
      );
  static String get legalNotice => _('Mentions légales', 'Legal notice');
  static String get publisher => _('Éditeur', 'Publisher');
  static String get host => _('Hébergeur', 'Hosting provider');
  static String lastUpdated(String d) =>
      _('Dernière mise à jour : $d', 'Last updated: $d');
  static String contactLine(String c) => _('Contact : $c', 'Contact: $c');

  // — Notifications de reconquête (conversion) —
  static String get notifAbandon1Title =>
      _('Ta métamorphose t’attend ✨', 'Your metamorphosis awaits ✨');
  static String notifAbandon1Body(String s) => _(
        'Ton style « $s » est prêt. Reviens le générer en un tap.',
        'Your « $s » style is ready. Come back and generate it in one tap.',
      );
  static String get notifAbandon2Title =>
      _('Tu y étais presque 👀', 'You were so close 👀');
  static String notifAbandon2Body(String s) => _(
        'Débloque « $s » et découvre enfin ton résultat.',
        'Unlock « $s » and finally reveal your result.',
      );
  static String get notifInactiveTitle =>
      _('De nouveaux styles t’attendent 🔥', 'New styles are waiting 🔥');
  static String get notifInactiveBody => _(
        'Reviens créer ta prochaine métamorphose sur Morfo.',
        'Come back and create your next metamorphosis on Morfo.',
      );
  static String get notifWelcomeTitle => _(
        'Prêt pour ta 1re métamorphose ? ✨',
        'Ready for your first metamorphosis? ✨',
      );
  static String get notifWelcomeBody => _(
        'Choisis un style et transforme ta photo en quelques secondes.',
        'Pick a style and transform your photo in seconds.',
      );
  static String get notifCreditsTitle =>
      _('Plus de crédits ? ⚡', 'Out of credits? ⚡');
  static String get notifCreditsBody => _(
        'Recharge en un tap et continue tes métamorphoses.',
        'Top up in one tap and keep transforming.',
      );
  static String get notifDiscountTitle =>
      _('-50 % rien que pour toi 🎁', '-50% just for you 🎁');
  static String get notifDiscountBody => _(
        'Reviens sur Morfo : ton abonnement à moitié prix, pour une durée limitée.',
        'Come back to Morfo: your subscription half price, for a limited time.',
      );
  static String get notifPostShareTitle =>
      _('On remet ça ? ✨', 'Round two? ✨');
  static String get notifPostShareBody => _(
        'Crée une nouvelle carte, ton feed va adorer.',
        'Create another card — your feed will love it.',
      );
}
