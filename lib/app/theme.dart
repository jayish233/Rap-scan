import 'package:flutter/material.dart';

import '../domain/rating.dart';
import '../domain/scan_result.dart';

/// Colour tokens from the design handoff spec (rapscanz-design-handoff/
/// RAPSCANZ_FLUTTER_DESIGN_SPEC.md §2). Every semantic colour in the app
/// maps to one of these — never a raw hex in a widget.
abstract final class AppColors {
  // Surfaces & text
  static const background = Color(0xFFFAFDFA);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFF1F6F2); // iOS chip / tint background
  static const surfaceContainer = Color(0xFFEEF4EF); // Android tonal cards, nav bar
  static const segmentTrack = Color(0xFFE8EFEA); // iOS segmented track, progress track
  static const text = Color(0xFF1D242B); // onSurface
  static const textMuted = Color(0xFF5C6670);
  static const border = Color(0xFFE3EBE5); // iOS hairlines
  static const borderStrong = Color(0xFFCBD5CD); // Android card borders
  static const inputOutline = Color(0xFF6F7A72); // Android input outline

  // Brand
  static const primary = Color(0xFF1B7746);
  static const onPrimary = Color(0xFFFFFFFF);
  static const accent = Color(0xFF72D66F); // leaf green
  static const onAccent = Color(0xFF14301F);
  static const teal = Color(0xFF19C8C0); // logo gradient stop
  static const logoGreen = Color(0xFF3FD68A); // logo gradient start
  static const tonal = Color(0xFFCDEFCB); // Android selected / tonal buttons
  static const onTonal = Color(0xFF0A2E17);

  // Status (rating colours: good = success, okay = accent, caution = warning,
  // avoid = danger)
  static const success = Color(0xFF4CC27C);
  static const warning = Color(0xFFF0A63A);
  static const danger = Color(0xFFD13A2E);
  static const rose = Color(0xFFFB7185);

  // Severity (body-map harm dots)
  static const severityLow = Color(0xFFFBBF24);
  static const severityMedium = Color(0xFFFB923C);
  static const severityHigh = Color(0xFFEF4444);

  // Severity chip backgrounds (cautions list)
  static const severityChipLowBg = Color(0xFFEDF2EE);
  static const severityChipLowText = Color(0xFF3F4A52);

  // Organ benefit greens
  static const benefitLow = Color(0xFF86EFAC);
  static const benefitMedium = Color(0xFF22C55E);
  static const benefitHigh = Color(0xFF15803D);

  // Dietary marks (Indian convention; mockups: green square veg, red non-veg)
  static const veg = Color(0xFF22A05A);
  static const nonVeg = Color(0xFFD13A2E);
  static const vegan = Color(0xFF4D7C0F);

  // Dark panels (viewfinder, body-map card)
  static const darkPanel = Color(0xFF0F1A14);
  static const onDarkMuted = Color(0xFFC9D6CD);
  static const laser = Color(0xFF5FE3D6);

  // Health score ring (dark disc)
  static const ringDisc = Color(0xFF0B1220);
  static const ringTrack = Color(0xFF334155);
  static const ringGood = Color(0xFF34D399);
  static const ringGoodText = Color(0xFF6EE7B7);
  static const ringMid = Color(0xFFFCD34D);
  static const ringMidText = Color(0xFFFDE68A);
  static const ringBad = Color(0xFFFB7185);
  static const ringBadText = Color(0xFFFDA4AF);
  static const ringSubtext = Color(0xFF94A3B8);

  // Rank badges
  static const gold = Color(0xFFF2C94C);
  static const silver = Color(0xFFC9D1D6);
  static const bronze = Color(0xFFE0A66B);

  // Amber accents (kcal chip, percentage chip, warning icon)
  static const amberTint = Color(0x2EF0A63A); // rgba(240,166,58,.18)
  static const amberTintStrong = Color(0x33F0A63A); // percentage chip bg
  static const amberText = Color(0xFFA86400);
  static const percentText = Color(0xFF7A4B00);
  static const cautionText = Color(0xFF5E3A00);
  static const warnIcon = Color(0xFFC98200);

  // "You" row on the leaderboard (iOS)
  static const youRowBg = Color(0xFFE4F6E3);
}

/// Font families bundled in pubspec.yaml (spec §2).
abstract final class AppFonts {
  static const display = 'BricolageGrotesque'; // headings, scores: 700–800, ≈ -3.5% spacing
  static const body = 'PlusJakartaSans';
}

abstract final class AppSizes {
  /// Max content width on tablets (design.md §1).
  static const maxContentWidth = 640.0;
  static const gutter = 16.0;
  static const radius = 14.0;

  /// Platform radii (spec §2): iOS cards 16–24 / buttons 14–16;
  /// Android cards 16–20 / buttons fully rounded (26) / inputs 4.
  static const cardRadiusIos = 20.0;
  static const cardRadiusAndroid = 16.0;
  static const buttonRadiusIos = 16.0;
  static const buttonRadiusAndroid = 26.0;
  static const inputRadiusIos = 14.0;
  static const inputRadiusAndroid = 4.0;

  /// Touch targets: 44 iOS / 48 Android.
  static const touchIos = 44.0;
  static const touchAndroid = 48.0;
  static const minTouchTarget = touchAndroid;

  /// Hard offset brand shadow (leaf green).
  static const hardShadowOffset = Offset(4, 4);
  static const hardShadowOffsetLarge = Offset(5, 5);
}

ThemeData buildAppTheme() {
  const scheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    secondary: AppColors.accent,
    onSecondary: AppColors.onAccent,
    tertiary: AppColors.teal,
    onTertiary: AppColors.onPrimary,
    error: AppColors.danger,
    onError: AppColors.onPrimary,
    surface: AppColors.surface,
    onSurface: AppColors.text,
    onSurfaceVariant: AppColors.textMuted,
    surfaceContainerLowest: AppColors.surface,
    surfaceContainerLow: AppColors.surfaceMuted,
    surfaceContainer: AppColors.surfaceContainer,
    secondaryContainer: AppColors.tonal,
    onSecondaryContainer: AppColors.onTonal,
    outline: AppColors.inputOutline,
    outlineVariant: AppColors.border,
  );

  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: AppFonts.body,
    splashFactory: InkSparkle.splashFactory,
  );
  final text = base.textTheme.apply(bodyColor: AppColors.text, displayColor: AppColors.text);

  TextStyle display(TextStyle? s, double size, FontWeight w, {double spacing = -0.035}) =>
      (s ?? const TextStyle()).copyWith(
        fontFamily: AppFonts.display,
        fontSize: size,
        fontWeight: w,
        letterSpacing: size * spacing,
        height: 1.08,
        color: AppColors.text,
      );

  final textTheme = text.copyWith(
    displayLarge: display(text.displayLarge, 38, FontWeight.w700),
    displayMedium: display(text.displayMedium, 34, FontWeight.w700),
    displaySmall: display(text.displaySmall, 32, FontWeight.w700),
    headlineLarge: display(text.headlineLarge, 34, FontWeight.w700), // iOS page titles
    headlineMedium: display(text.headlineMedium, 26, FontWeight.w700), // Android page titles
    headlineSmall: display(text.headlineSmall, 24, FontWeight.w700),
    titleLarge: display(text.titleLarge, 22, FontWeight.w700, spacing: -0.03),
    titleMedium: display(text.titleMedium, 18, FontWeight.w700, spacing: -0.03),
    titleSmall: text.titleSmall?.copyWith(fontWeight: FontWeight.w600),
    labelLarge: text.labelLarge?.copyWith(fontWeight: FontWeight.w600),
  );

  return base.copyWith(
    scaffoldBackgroundColor: AppColors.background,
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.text,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: textTheme.headlineSmall,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(AppSizes.minTouchTarget, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.buttonRadiusAndroid)),
        textStyle: const TextStyle(fontFamily: AppFonts.body, fontWeight: FontWeight.w600, fontSize: 16),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(AppSizes.minTouchTarget, AppSizes.minTouchTarget),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        side: const BorderSide(color: AppColors.inputOutline),
        foregroundColor: AppColors.primary,
        textStyle: const TextStyle(fontFamily: AppFonts.body, fontWeight: FontWeight.w600, fontSize: 15),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(AppSizes.touchIos, AppSizes.touchIos),
        foregroundColor: AppColors.primary,
        textStyle: const TextStyle(fontFamily: AppFonts.body, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      labelStyle: const TextStyle(color: AppColors.textMuted),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.inputRadiusAndroid),
        borderSide: const BorderSide(color: AppColors.inputOutline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.inputRadiusAndroid),
        borderSide: const BorderSide(color: AppColors.inputOutline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.inputRadiusAndroid),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.inputRadiusAndroid),
        borderSide: const BorderSide(color: AppColors.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.inputRadiusAndroid),
        borderSide: const BorderSide(color: AppColors.danger, width: 2),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusAndroid),
        side: const BorderSide(color: AppColors.borderStrong),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surfaceContainer,
      surfaceTintColor: Colors.transparent,
      indicatorColor: AppColors.tonal,
      height: 72,
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected) ? AppColors.onTonal : AppColors.textMuted,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontFamily: AppFonts.body,
          fontSize: 12,
          fontWeight: states.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
          color: states.contains(WidgetState.selected) ? AppColors.text : AppColors.textMuted,
        ),
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.primary),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    dividerTheme: const DividerThemeData(color: AppColors.border, space: 1),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        minimumSize: WidgetStateProperty.all(const Size(0, 48)),
        textStyle: WidgetStateProperty.all(const TextStyle(fontFamily: AppFonts.body, fontSize: 14, fontWeight: FontWeight.w600)),
        side: WidgetStateProperty.all(const BorderSide(color: AppColors.inputOutline)),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? AppColors.onTonal : AppColors.text,
        ),
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? AppColors.tonal : AppColors.surface,
        ),
      ),
    ),
  );
}

/// Semantic tone → colour token (rating chips, banners).
Color toneColor(Tone tone) => switch (tone) {
      Tone.success => AppColors.success,
      Tone.accent => AppColors.accent,
      Tone.warning => AppColors.warning,
      Tone.danger => AppColors.danger,
      Tone.rose => AppColors.rose,
    };

/// Caution / organ-harm severity colour.
Color severityColor(Severity severity) => switch (severity) {
      Severity.low => AppColors.severityLow,
      Severity.medium => AppColors.severityMedium,
      Severity.high => AppColors.severityHigh,
    };
