import 'paywall_service.dart';
// Import conditionnel : web/desktop → stub ; mobile (io) → branchement Superwall.
import 'paywall_service_stub_platform.dart'
    if (dart.library.io) 'paywall_service_io.dart' as impl;

/// Fabrique le service de paywall distant adapté à la plateforme.
///
/// - **Web / desktop** → [StubPaywallService] (aucun paywall distant → l'app
///   utilise son paywall natif de secours).
/// - **Mobile** → point de branchement Superwall (voir `integration/INTEGRATION.md`).
PaywallService createPaywallService(String superwallApiKey) =>
    impl.createPaywallService(superwallApiKey);
