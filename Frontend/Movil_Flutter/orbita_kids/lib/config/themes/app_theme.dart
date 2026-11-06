import 'package:flutter/material.dart';

import 'package:orbita_kids/config/themes/app_colors.dart';
import 'package:orbita_kids/config/themes/app_spacing.dart';
import 'package:orbita_kids/config/themes/app_text_styles.dart';

export 'package:orbita_kids/config/themes/app_text_styles.dart'
    show kBodyFont, kDisplayFont;

/// Tema Material 3 con la identidad de Órbita Kids.
ThemeData buildTheme({required bool dark, required bool highContrast}) {
  var c = dark ? OkColors.dark : OkColors.light;
  if (highContrast) c = c.toHighContrast(dark);
  final scheme =
      ColorScheme.fromSeed(
        seedColor: Brand.purple,
        brightness: dark ? Brightness.dark : Brightness.light,
      ).copyWith(
        primary: dark ? Brand.violet : Brand.purple,
        onPrimary: dark ? Brand.space : Colors.white,
        secondary: Brand.yellow,
        onSecondary: Brand.ink,
        tertiary: Brand.mint,
        surface: c.bg,
        onSurface: c.ink,
        surfaceContainerLowest: c.card,
        surfaceContainerLow: c.card,
        surfaceContainer: c.card,
        surfaceContainerHigh: c.soft,
        onSurfaceVariant: c.muted,
        outline: c.line,
        outlineVariant: c.line,
        error: c.err,
      );

  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    brightness: scheme.brightness,
    fontFamily: kBodyFont,
    scaffoldBackgroundColor: c.bg,
    extensions: [c],
    materialTapTargetSize: MaterialTapTargetSize.padded,
    visualDensity: VisualDensity.standard,
  );

  TextStyle d(double size, [FontWeight w = FontWeight.w600]) => TextStyle(
    fontFamily: kDisplayFont,
    fontSize: size,
    fontWeight: w,
    height: 1.15,
    color: c.ink,
  );

  final text = base.textTheme
      .apply(fontFamily: kBodyFont, bodyColor: c.ink, displayColor: c.ink)
      .copyWith(
        displaySmall: d(34),
        headlineLarge: d(30),
        headlineMedium: d(26),
        headlineSmall: d(23),
        titleLarge: d(20),
        titleMedium: d(17),
        titleSmall: const TextStyle(
          fontFamily: kBodyFont,
          fontWeight: FontWeight.w800,
          fontSize: 15,
        ),
        bodyLarge: TextStyle(fontSize: 16.5, height: 1.45, color: c.ink),
        bodyMedium: TextStyle(fontSize: 15, height: 1.45, color: c.ink),
        bodySmall: TextStyle(
          fontSize: 13.5,
          height: 1.4,
          color: c.muted,
          fontWeight: FontWeight.w600,
        ),
        labelLarge: const TextStyle(
          fontFamily: kBodyFont,
          fontWeight: FontWeight.w800,
          fontSize: 16.5,
        ),
      );

  final radius = AppRadius.card;
  final hcBorder = highContrast
      ? BorderSide(color: c.ink, width: 2)
      : BorderSide.none;

  return base.copyWith(
    textTheme: text,
    appBarTheme: AppBarTheme(
      backgroundColor: c.bg,
      foregroundColor: c.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: d(21),
    ),
    cardTheme: CardThemeData(
      color: c.card,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: highContrast ? hcBorder : BorderSide(color: c.line),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 56),
        textStyle: text.labelLarge,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.card,
          side: hcBorder,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(64, 52),
        textStyle: text.labelLarge,
        foregroundColor: c.ink,
        side: BorderSide(color: highContrast ? c.ink : c.line, width: 2),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(48, 48),
        foregroundColor: c.purpleDark,
        textStyle: const TextStyle(
          fontFamily: kBodyFont,
          fontWeight: FontWeight.w800,
          fontSize: 15,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.card,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: AppRadius.field,
        borderSide: BorderSide(color: highContrast ? c.ink : c.line, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.field,
        borderSide: BorderSide(color: highContrast ? c.ink : c.line, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.field,
        borderSide: BorderSide(color: scheme.primary, width: 2.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppRadius.field,
        borderSide: BorderSide(color: c.err, width: 2),
      ),
      labelStyle: TextStyle(color: c.muted, fontWeight: FontWeight.w700),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: c.card,
      selectedColor: c.tintViolet,
      side: BorderSide(color: highContrast ? c.ink : c.line, width: 1.5),
      labelStyle: TextStyle(
        color: c.ink,
        fontWeight: FontWeight.w700,
        fontFamily: kBodyFont,
      ),
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: c.card,
      indicatorColor: c.tintViolet,
      height: 72,
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(
          fontFamily: kBodyFont,
          fontWeight: FontWeight.w800,
          fontSize: 12.5,
          color: c.ink,
        ),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? Colors.white : null,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? scheme.primary : null,
      ),
    ),
    dividerTheme: DividerThemeData(color: c.line, thickness: 1, space: 1),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: dark ? const Color(0xFF2E337F) : Brand.ink,
      contentTextStyle: const TextStyle(
        fontFamily: kBodyFont,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.field),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: c.card,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.sheet),
      titleTextStyle: d(22),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: c.card,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: scheme.primary,
      linearTrackColor: c.line,
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        selectedBackgroundColor: c.tintViolet,
        selectedForegroundColor: c.inkViolet,
        side: BorderSide(color: highContrast ? c.ink : c.line, width: 1.5),
        textStyle: const TextStyle(
          fontFamily: kBodyFont,
          fontWeight: FontWeight.w800,
        ),
        minimumSize: const Size(48, 48),
      ),
    ),
  );
}
