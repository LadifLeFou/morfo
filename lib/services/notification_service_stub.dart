import 'notification_service.dart';

/// Web / desktop : pas de notifications locales natives → démo (no-op).
NotificationService createNotificationService() => DemoNotificationService();
