import 'notification_service.dart';
// Import conditionnel : web/desktop → stub ; mobile (io) → branchement natif.
import 'notification_service_stub.dart'
    if (dart.library.io) 'notification_service_io.dart' as impl;

/// Fabrique le service de notifications adapté à la plateforme.
///
/// - **Web / desktop** → [DemoNotificationService] (no-op).
/// - **Mobile** → point de branchement `flutter_local_notifications`
///   (voir `integration/INTEGRATION.md`).
NotificationService createNotificationService() =>
    impl.createNotificationService();
