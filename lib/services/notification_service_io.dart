import 'notification_service.dart';

/// Mobile (iOS / Android) — point de branchement `flutter_local_notifications`.
///
/// Tant que le SDK n'est pas ajouté, on renvoie la démo (no-op) pour ne casser
/// aucun build. Pour l'activer (voir `integration/INTEGRATION.md`) :
///
/// 1. `flutter pub add flutter_local_notifications timezone`
/// 2. Copier `integration/notification_service_local.dart.example`
///    → `lib/services/notification_service_local.dart`
/// 3. Remplacer le corps ci-dessous par :
///    ```dart
///    return LocalNotificationService();
///    ```
NotificationService createNotificationService() => DemoNotificationService();
