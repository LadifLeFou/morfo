import 'dart:ui';

import 'models/morfo_category.dart';

/// Localisation légère — suit la langue de l'appareil.
///
/// FR si l'appareil est en français, sinon anglais (défaut international).
/// Extensible à d'autres langues en ajoutant des branches.
class S {
  static bool _fr = false;

  /// À appeler au démarrage (avant runApp).
  static void init() {
    _fr = PlatformDispatcher.instance.locale.languageCode.toLowerCase() == 'fr';
  }

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

  static String category(MorfoCategory c) => switch (c) {
        MorfoCategory.tendance => _('Tendance', 'Trending'),
        MorfoCategory.aesthetic => 'Aesthetic',
        MorfoCategory.fun => 'Fun',
        MorfoCategory.jeux => _('Jeux', 'Games'),
        MorfoCategory.cinema => _('Cinéma', 'Cinema'),
      };

  // — Génération —
  static String get genStep1 => _('Analyse du visage…', 'Analyzing face…');
  static String get genStep2 => _('Application du style…', 'Applying style…');
  static String get genStep3 => _('Rendu final…', 'Final render…');
  static List<String> get genSteps => <String>[genStep1, genStep2, genStep3];
  static String get genVideo => _('Création de ta vidéo…', 'Creating your video…');
  static String get genWaitImage => _('Cela prend quelques secondes', 'This takes a few seconds');
  static String get genWaitVideo => _('La vidéo prend 1 à 2 minutes', 'Video takes 1 to 2 minutes');
  static String get noFace => _('Aucun visage détecté. Utilise une photo de face, nette et bien éclairée.', 'No face detected. Use a clear, well-lit, front-facing photo.');

  // — Résultat —
  static String get yourResult => _('Ton résultat', 'Your result');
  static String get yourCard => _('Ta carte', 'Your card');
  static String get beforeAfter => _('Avant / Après', 'Before / After');
  static String get tryAnotherStyle => _('Essayer un autre style', 'Try another style');
  static String get savedToGallery => _('Enregistré dans ta galerie.', 'Saved to your gallery.');
  static String get saved => _('Enregistré', 'Saved');
  static String get shareUnavailable => _('Partage indisponible.', 'Sharing unavailable.');
  static String shareText(String t) => _('Ma métamorphose « $t » avec Morfo ✨', 'My « $t » metamorphosis with Morfo ✨');

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
