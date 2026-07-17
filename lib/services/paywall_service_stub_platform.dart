import 'paywall_service.dart';

/// Web / desktop : pas de paywall distant → stub (paywall natif utilisé).
PaywallService createPaywallService(String superwallApiKey) =>
    const StubPaywallService();
