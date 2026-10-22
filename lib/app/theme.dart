import 'package:flutter/material.dart';

/// Colour tokens (design.md §2.1). Every semantic colour in the app maps to
/// one of these — never a raw hex in a widget.
abstract final class AppColors {
  static const surface = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFF3F7F4);
  static const border = Color(0xFFDDE5DF);
  static const text = Color(0xFF1E2622); // charcoal
  static const textMuted = Color(0xFF5A665F);

  static const primary = Color(0xFF166534); // deep green
  static const onPrimary = Color(0xFFFFFFFF);
  static const accent = Color(0xFF5BB318); // fresh leaf green
  static const teal = Color(0xFF0F9488); // logo gradient stop

  static const success = Color(0xFF16A34A);
  static const warning = Color(0xFFD97706);
  static const danger = Color(0xFFDC2626);
  static const rose = Color(0xFFE11D48);

  static const severityLow = Color(0xFFF59E0B);
  static const severityMedium = Color(0xFFEA580C);
  static const severityHigh = Color(0xFFDC2626);

  static const benefitLow = Color(0xFF86EFAC);
  static const benefitMedium = Color(0xFF22C55E);
  static const benefitHigh = Color(0xFF15803D);

  static const veg = Color(0xFF15803D);
  static const nonVeg = Color(0xFF8B3A1A);
  static const vegan = Color(0xFF4D7C0F);
}

/// Font families bundled in pubspec.yaml (design.md §2.2).
abstract final class AppFonts {
  static const display = 'BricolageGrotesque';
  static const body = 'PlusJakartaSans';
}

abstract final class AppSizes {
  /// Max content width on tablets (design.md §1).
  static const maxContentWidth = 640.0;
  static const gutter = 16.0;
  static const radius = 14.0;
  static const minTouchTarget = 48.0;

  /// Hard offset shadow on marketing cards (design.md §1).
  static const hardShadowOffset = Offset(4, 4);
}

ThemeData buildAppTheme() {
  const scheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    secondary: AppColors.accent,
    onSecondary: AppColors.text,
    tertiary: AppColors.teal,
    onTertiary: AppColors.onPrimary,
    error: AppColors.danger,
    onError: AppColors.onPrimary,
    surface: AppColors.surface,
    onSurface: AppColors.text,
    onSurfaceVariant: AppColors.textMuted,
    surfaceContainerLowest: AppColors.surface,
    surfaceContainerLow: AppColors.surfaceMuted,
    surfaceContainer: AppColors.surfaceMuted,
    outline: AppColors.border,
    outlineVariant: AppColors.border,
  );

  final base = ThemeData(useMaterial3: true, colorScheme: scheme, fontFamily: AppFonts.body);
  TextStyle display(TextStyle? s, FontWeight w) =>
      (s ?? const TextStyle()).copyWith(fontFamily: AppFonts.display, fontWeight: w, color: AppColors.text);

  final text = base.textTheme.apply(bodyColor: AppColors.text, displayColor: AppColors.text);
  final textTheme = text.copyWith(
    displayLarge: display(text.displayLarge, FontWeight.w800),
    displayMedium: display(text.displayMedium, FontWeight.w800),
    displaySmall: display(text.displaySmall, FontWeight.w800),
    headlineLarge: display(text.headlineLarge, FontWeight.w800),
    headlineMedium: display(text.headlineMedium, FontWeight.w700),
    headlineSmall: display(text.headlineSmall, FontWeight.w700),
    titleLarge: display(text.titleLarge, FontWeight.w700),
  );

  final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radius));
  const buttonSize = Size(AppSizes.minTouchTarget, 52);

  return base.copyWith(
    scaffoldBackgroundColor: AppColors.surface,
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.text,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      titleTextStyle: textTheme.titleLarge,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: buttonSize,
        shape: shape,
        textStyle: const TextStyle(fontFamily: AppFonts.body, fontWeight: FontWeight.w700, fontSize: 16),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: buttonSize,
        shape: shape,
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        foregroundColor: AppColors.primary,
        textStyle: const TextStyle(fontFamily: AppFonts.body, fontWeight: FontWeight.w700, fontSize: 16),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(AppSizes.minTouchTarget, AppSizes.minTouchTarget),
        foregroundColor: AppColors.primary,
        textStyle: const TextStyle(fontFamily: AppFonts.body, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceMuted,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radius)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radius),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radius),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radius),
        side: const BorderSide(color: AppColors.border),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: AppColors.primary.withValues(alpha: 0.12),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected) ? AppColors.primary : AppColors.textMuted,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontFamily: AppFonts.body,
          fontSize: 12,
          fontWeight: states.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
          color: states.contains(WidgetState.selected) ? AppColors.primary : AppColors.textMuted,
        ),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    dividerTheme: const DividerThemeData(color: AppColors.border, space: 1),
  );
}
