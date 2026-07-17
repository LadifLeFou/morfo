import 'package:go_router/go_router.dart';

import '../core/models/generation_result.dart';
import '../core/models/template.dart';
import '../features/credits/presentation/credits_screen.dart';
import '../features/generation/generate_args.dart';
import '../features/generation/presentation/custom_prompt_screen.dart';
import '../features/generation/presentation/generation_screen.dart';
import '../features/generation/presentation/import_screen.dart';
import '../features/history/presentation/history_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/legal/legal_screen.dart';
import '../features/home/presentation/template_detail_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/paywall/presentation/paywall_screen.dart';
import '../features/result/presentation/result_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/splash/presentation/splash_screen.dart';

/// Routeur de l'app (deep links prêts).
final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: <RouteBase>[
    GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
    GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
    GoRoute(
      path: '/paywall',
      builder: (_, GoRouterState state) =>
          PaywallScreen(resumeArgs: state.extra as GenerateArgs?),
    ),
    GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
    GoRoute(
      path: '/template',
      builder: (_, GoRouterState state) =>
          TemplateDetailScreen(template: state.extra! as Template),
    ),
    GoRoute(
      path: '/import',
      builder: (_, GoRouterState state) =>
          ImportScreen(template: state.extra! as Template),
    ),
    GoRoute(path: '/custom', builder: (_, _) => const CustomPromptScreen()),
    GoRoute(
      path: '/generate',
      builder: (_, GoRouterState state) =>
          GenerationScreen(args: state.extra! as GenerateArgs),
    ),
    GoRoute(
      path: '/result',
      builder: (_, GoRouterState state) =>
          ResultScreen(result: state.extra! as GenerationResult),
    ),
    GoRoute(
      path: '/terms',
      builder: (_, _) => const LegalScreen(doc: LegalDoc.terms),
    ),
    GoRoute(
      path: '/privacy',
      builder: (_, _) => const LegalScreen(doc: LegalDoc.privacy),
    ),
    GoRoute(path: '/history', builder: (_, _) => const HistoryScreen()),
    GoRoute(path: '/credits', builder: (_, _) => const CreditsScreen()),
    GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
  ],
);
