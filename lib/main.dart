import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/router.dart';
import 'core/persistence.dart';
import 'design_system/morfo_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

class MorfoApp extends StatelessWidget {
  const MorfoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Morfo',
      debugShowCheckedModeBanner: false,
      theme: MorfoTheme.dark,
      routerConfig: appRouter,
    );
  }
}
