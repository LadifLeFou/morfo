import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'notification_service_factory.dart';

/// Contrat notifications locales — implémenté par `flutter_local_notifications`
/// sur mobile, no-op sur web/desktop (voir `integration/INTEGRATION.md`).
abstract interface class NotificationService {
  Future<void> init();

  /// Demande l'autorisation d'envoyer des notifications. true si accordée.
  Future<bool> requestPermission();

  /// Planifie une notification locale [after] une durée donnée.
  ///
  /// [payload] est une route de deep-link (ex. `/paywall`) ouverte au tap.
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required Duration after,
    String? payload,
  });

  Future<void> cancel(int id);
  Future<void> cancelAll();

  /// Émet la route (payload) quand l'utilisateur tape une notification.
  Stream<String> get onSelect;
}

/// Implémentation de démo : journalise au lieu d'envoyer (web/dev). Permet de
/// vérifier la logique de campagnes sans SDK natif.
class DemoNotificationService implements NotificationService {
  final StreamController<String> _taps = StreamController<String>.broadcast();

  @override
  Stream<String> get onSelect => _taps.stream;

  @override
  Future<void> init() async {}

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required Duration after,
    String? payload,
  }) async {
    if (kDebugMode) {
      debugPrint(
        '[notif#$id +${after.inMinutes}min → ${payload ?? '/'}] $title — $body',
      );
    }
  }

  @override
  Future<void> cancel(int id) async {
    if (kDebugMode) debugPrint('[notif#$id] annulée');
  }

  @override
  Future<void> cancelAll() async {
    if (kDebugMode) debugPrint('[notif] toutes annulées');
  }
}

/// Sélectionne l'implémentation native (mobile) ou la démo (web/desktop) via la
/// factory à imports conditionnels.
final Provider<NotificationService> notificationServiceProvider =
    Provider<NotificationService>((Ref ref) => createNotificationService());
