import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:async';

import 'app/app_state.dart';
import 'app/router.dart';
import 'core/persistence.dart';
import 'core/strings.dart';
import 'design_system/morfo_theme.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  S.init();

  // .env est bundlé comme asset ; en cas d'absence on retombe sur le mock.
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {}

  final SharedPreferences sp = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [prefsProvider.overrideWithValue(Prefs(sp))],
      child: const MorfoApp(),
    ),
  );
}

class MorfoApp extends ConsumerStatefulWidget {
  const MorfoApp({super.key});

  @override
  ConsumerState<MorfoApp> createState() => _MorfoAppState();
}

class _MorfoAppState extends ConsumerState<MorfoApp> {
  StreamSubscription<String>? _notifTaps;

  @override
  void initState() {
    super.initState();
    // Deep-link : taper une notification ouvre la route associée (payload).
    _notifTaps = ref.read(notificationServiceProvider).onSelect.listen(
      (String route) {
        if (route.isNotEmpty) appRouter.go(route);
      },
    );
  }

  @override
  void dispose() {
    _notifTaps?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // `S` expose des getters statiques : changer de langue n'invalide aucun
    // widget en soi. On force donc la reconstruction complète de l'arbre via
    // la clé. La route courante est préservée : `appRouter` est global et
    // conserve sa propre location.
    final AppLanguage language = ref.watch(languageProvider);

    return MaterialApp.router(
      key: ValueKey<AppLanguage>(language),
      title: 'Morfo',
      debugShowCheckedModeBanner: false,
      theme: MorfoTheme.dark,
      routerConfig: appRouter,
    );
  }
}
