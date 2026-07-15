import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'morfo_colors.dart';
import 'morfo_typography.dart';

/// Thème Morfo — dark-first, Material 3, ancré sur la palette et la typo.
abstract final class MorfoTheme {
  static ThemeData get dark {
    final ColorScheme scheme = const ColorScheme.dark(
      surface: MorfoColors.surface,
      onSurface: MorfoColors.ink,
      primary: MorfoColors.holoViolet,
      onPrimary: MorfoColors.voidColor,
      secondary: MorfoColors.holoCyan,
      onSecondary: MorfoColors.voidColor,
      error: MorfoColors.danger,
      onError: MorfoColors.voidColor,
      outline: MorfoColors.stroke,
    ).copyWith(surfaceContainerHighest: MorfoColors.surface2);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: MorfoColors.voidColor,
      colorScheme: scheme,
      fontFamily: MorfoType.bodyFamily,
      textTheme: _textTheme,
      // Interactions sobres : pas de splash Material bruyant.
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      iconTheme: const IconThemeData(color: MorfoColors.ink),
      dividerColor: MorfoColors.stroke,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        foregroundColor: MorfoColors.ink,
        titleTextStyle: MorfoType.titleMedium,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
    );
  }

  static const TextTheme _textTheme = TextTheme(
    displayLarge: MorfoType.displayLarge,
    displayMedium: MorfoType.displayMedium,
    displaySmall: MorfoType.titleLarge,
    headlineMedium: MorfoType.titleLarge,
    headlineSmall: MorfoType.titleMedium,
    titleLarge: MorfoType.titleMedium,
    titleMedium: MorfoType.titleSmall,
    titleSmall: MorfoType.label,
    bodyLarge: MorfoType.bodyLarge,
    bodyMedium: MorfoType.bodyMedium,
    labelLarge: MorfoType.label,
    bodySmall: MorfoType.caption,
    labelSmall: MorfoType.eyebrow,
  );
}
