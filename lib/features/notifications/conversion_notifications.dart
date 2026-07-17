import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/strings.dart';
import '../../services/notification_service.dart';

/// Orchestrateur des notifications de **reconquête / conversion**.
///
/// Encode QUELLES notifications envoyer, AVEC QUEL texte et QUAND. La couche
/// [NotificationService] gère l'envoi réel (natif sur mobile, no-op sur web).
///
/// Bonnes pratiques respectées :
/// - On ne demande la permission qu'au moment d'un vrai signal d'intention
///   (fin d'onboarding, génération lancée) — jamais au démarrage à froid.
/// - On **annule** les relances dès que l'utilisateur convertit.
/// - Chaque campagne a un id fixe → replanifiable / annulable proprement.
class ConversionNotifications {
  ConversionNotifications(this._notifs);

  final NotificationService _notifs;

  // Ids fixes par campagne.
  static const int _abandonedA = 101; // relance +1 h
  static const int _abandonedB = 102; // relance +24 h
  static const int _inactivity = 201; // inactivité +48 h
  static const int _discount = 202; // offre -50 % à +72 h d'inactivité
  static const int _credits = 301; // crédits épuisés
  static const int _welcome = 401; // onboarding fait, pas encore généré
  static const int _postShare = 501; // relance après un partage

  /// L'utilisateur a lancé une génération mais n'a **pas payé** (arrivé au
  /// paywall sans souscrire). C'est le plus fort levier : on le relance.
  Future<void> onGenerationAbandoned(String style) async {
    await _notifs.requestPermission();
    await _notifs.schedule(
      id: _abandonedA,
      title: S.notifAbandon1Title,
      body: S.notifAbandon1Body(style),
      after: const Duration(hours: 1),
      payload: '/paywall',
    );
    await _notifs.schedule(
      id: _abandonedB,
      title: S.notifAbandon2Title,
      body: S.notifAbandon2Body(style),
      after: const Duration(hours: 24),
      payload: '/paywall',
    );
    await _scheduleInactivity();
  }

  /// L'utilisateur a converti (abonnement) → on annule les relances de vente
  /// (abandon, offre -50 %, crédits) : plus de spam commercial.
  Future<void> onConverted() async {
    await _notifs.cancel(_abandonedA);
    await _notifs.cancel(_abandonedB);
    await _notifs.cancel(_discount);
    await _notifs.cancel(_credits);
  }

  /// Crédits épuisés (tentative de génération non finançable) → invite à
  /// recharger.
  Future<void> onCreditsEmpty() async {
    await _notifs.requestPermission();
    await _notifs.schedule(
      id: _credits,
      title: S.notifCreditsTitle,
      body: S.notifCreditsBody,
      after: const Duration(hours: 2),
      payload: '/credits',
    );
  }

  /// L'utilisateur vient de partager un résultat → on capitalise sur l'élan.
  Future<void> onShared() async {
    await _notifs.schedule(
      id: _postShare,
      title: S.notifPostShareTitle,
      body: S.notifPostShareBody,
      after: const Duration(hours: 6),
      payload: '/home',
    );
  }

  /// Fin d'onboarding : relance de bienvenue s'il ne génère pas tout de suite.
  Future<void> onOnboarded() async {
    await _notifs.requestPermission();
    await _notifs.schedule(
      id: _welcome,
      title: S.notifWelcomeTitle,
      body: S.notifWelcomeBody,
      after: const Duration(hours: 3),
      payload: '/home',
    );
    await _scheduleInactivity();
  }

  /// L'utilisateur est actif (ouverture du home) → on repousse la relance
  /// d'inactivité et on annule la bienvenue devenue inutile. L'offre -50 %
  /// n'est (re)programmée que pour les non-abonnés.
  Future<void> onActive({required bool subscribed}) async {
    await _notifs.cancel(_welcome);
    if (subscribed) await _notifs.cancel(_discount);
    await _scheduleInactivity(includeDiscount: !subscribed);
  }

  Future<void> _scheduleInactivity({bool includeDiscount = true}) async {
    await _notifs.schedule(
      id: _inactivity,
      title: S.notifInactiveTitle,
      body: S.notifInactiveBody,
      after: const Duration(hours: 48),
      payload: '/home',
    );
    if (!includeDiscount) return;
    // Après 3 jours sans activité : offre incitative -50 %.
    await _notifs.schedule(
      id: _discount,
      title: S.notifDiscountTitle,
      body: S.notifDiscountBody,
      after: const Duration(hours: 72),
      payload: '/paywall',
    );
  }
}

final Provider<ConversionNotifications> conversionNotificationsProvider =
    Provider<ConversionNotifications>(
  (Ref ref) => ConversionNotifications(ref.read(notificationServiceProvider)),
);
