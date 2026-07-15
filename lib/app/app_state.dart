import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/models/generation_result.dart';
import '../core/models/template.dart';
import '../core/persistence.dart';
import '../services/purchases_service.dart';
import '../services/service_providers.dart';

/// Crédits gratuits offerts à un nouvel utilisateur (démo).
const int kInitialCredits = 30;

// — Templates —
final FutureProvider<List<Template>> templatesProvider =
    FutureProvider<List<Template>>(
  (Ref ref) => ref.read(generationServiceProvider).fetchTemplates(),
);

// — Identifiant utilisateur (RevenueCat app user id) —
final Provider<String> appUserIdProvider =
    Provider<String>((Ref ref) => ref.read(purchasesServiceProvider).appUserId);

// — Onboarding —
class OnboardingNotifier extends Notifier<bool> {
  @override
  bool build() => ref.read(prefsProvider).onboarded;

  void complete() {
    state = true;
    ref.read(prefsProvider).setOnboarded(true);
  }
}

final NotifierProvider<OnboardingNotifier, bool> onboardingProvider =
    NotifierProvider<OnboardingNotifier, bool>(OnboardingNotifier.new);

// — Abonnement —
class SubscriptionNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  Future<void> refresh() async {
    state = await ref.read(purchasesServiceProvider).isSubscribed();
  }

  void setSubscribed(bool value) => state = value;
}

final NotifierProvider<SubscriptionNotifier, bool> subscriptionProvider =
    NotifierProvider<SubscriptionNotifier, bool>(SubscriptionNotifier.new);

// — Crédits —
class CreditsNotifier extends Notifier<int> {
  @override
  int build() => ref.read(prefsProvider).credits ?? kInitialCredits;

  bool canAfford(int cost) => state >= cost;

  void _persist() => ref.read(prefsProvider).setCredits(state);

  void add(int amount) {
    state = state + amount;
    _persist();
  }

  /// Réconcilie après une génération : valeur backend si connue, sinon décrément local.
  void applyOutcome(int cost, int creditsLeft) {
    final int next = creditsLeft >= 0 ? creditsLeft : state - cost;
    state = next < 0 ? 0 : next;
    _persist();
  }
}

final NotifierProvider<CreditsNotifier, int> creditsProvider =
    NotifierProvider<CreditsNotifier, int>(CreditsNotifier.new);

// — Historique —
class HistoryNotifier extends Notifier<List<GenerationResult>> {
  @override
  List<GenerationResult> build() => ref.read(prefsProvider).history;

  void add(GenerationResult result) {
    state = <GenerationResult>[result, ...state];
    ref.read(prefsProvider).setHistory(state);
  }

  void clear() {
    state = <GenerationResult>[];
    ref.read(prefsProvider).setHistory(state);
  }
}

final NotifierProvider<HistoryNotifier, List<GenerationResult>>
    historyProvider =
    NotifierProvider<HistoryNotifier, List<GenerationResult>>(
        HistoryNotifier.new);
