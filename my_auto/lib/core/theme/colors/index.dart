import 'package:flutter/material.dart';

/// Garage brand palette — aligned to the Muskun / Pickolab design system.
///
/// Scales: Primary (green), Secondary (neutral grey), Success, Error,
/// Warning, Information, plus Soft / Light / Stroke helpers.
class AppPalette {
  AppPalette._();

  // ── Primary (Neutral green) ──────────────────────────────────────────
  static const primary100 = Color(0xFFD0F1D2);
  static const primary200 = Color(0xFFB8ECBC);
  static const primary300 = Color(0xFF9AE39E);
  static const primary400 = Color(0xFF86DD8E);
  static const primary500 = Color(0xFF67D570);
  static const primary600 = Color(0xFF5EC266);
  static const primary700 = Color(0xFF4E9455);
  static const primary800 = Color(0xFF39753F);
  static const primary900 = Color(0xFF2C5930);

  // ── Secondary (Neutral grey) ─────────────────────────────────────────
  static const secondary0 = Color(0xFFFFFFFF);
  static const secondary100 = Color(0xFFE5E5E5);
  static const secondary200 = Color(0xFFBDBEC0);
  static const secondary300 = Color(0xFF9D9EA2);
  static const secondary400 = Color(0xFF717276);
  static const secondary500 = Color(0xFF53565B);
  static const secondary600 = Color(0xFF292C31);
  static const secondary700 = Color(0xFF1C1F24);
  static const secondary800 = Color(0xFF18191D);
  static const secondary900 = Color(0xFF121315);

  /// Legacy carbon aliases → secondary scale (existing call sites).
  static const carbon900 = secondary900;
  static const carbon850 = Color(0xFF15161A);
  static const carbon800 = secondary800;
  static const carbon700 = secondary700;
  static const carbon600 = secondary600;
  static const carbon500 = secondary500;
  static const carbon400 = secondary400;
  static const carbon300 = secondary300;
  static const carbon200 = secondary200;
  static const carbon100 = secondary100;
  static const carbon50 = softGrey;

  // ── Success ──────────────────────────────────────────────────────────
  static const success100 = Color(0xFFE7F7ED);
  static const success200 = Color(0xFFDBF3E5);
  static const success300 = Color(0xFFB3E6C7);
  static const success400 = Color(0xFF049D42);
  static const success500 = Color(0xFF049D42);
  static const success600 = Color(0xFF0A8B39);
  static const success700 = Color(0xFF0B652F);
  static const success800 = Color(0xFF054E21);
  static const success900 = Color(0xFF043D1A);

  static const success = success500;
  static const successSoft = success200;

  // ── Error ────────────────────────────────────────────────────────────
  static const error100 = Color(0xFFFBE8D9);
  static const error200 = Color(0xFFF7CBB2);
  static const error300 = Color(0xFFF2A88B);
  static const error400 = Color(0xFFF0886F);
  static const error500 = Color(0xFFEC5741);
  static const error600 = Color(0xFFCA3C32);
  static const error700 = Color(0xFFA43627);
  static const error800 = Color(0xFF871F26);
  static const error900 = Color(0xFF701826);

  static const danger = error600;
  static const dangerSoft = error100;

  // ── Warning ──────────────────────────────────────────────────────────
  static const warning100 = Color(0xFFFEF4AF);
  static const warning200 = Color(0xFFFFED89);
  static const warning300 = Color(0xFFFFE455);
  static const warning400 = Color(0xFFFFDF34);
  static const warning500 = Color(0xFFFFD801);
  static const warning600 = Color(0xFFE9C501);
  static const warning700 = Color(0xFFB59600);
  static const warning800 = Color(0xFF92843B);
  static const warning900 = Color(0xFF6B5C01);

  static const warning = warning500;

  // ── Information ──────────────────────────────────────────────────────
  static const info100 = Color(0xFFE5F3FE);
  static const info200 = Color(0xFF8AC7FE);
  static const info300 = Color(0xFF54ADFF);
  static const info400 = Color(0xFF329DFF);
  static const info500 = Color(0xFF0183FF);
  static const info600 = Color(0xFF0079E8);
  static const info700 = Color(0xFF005DB1);
  static const info800 = Color(0xFF0A4A94);
  static const info900 = Color(0xFF00386B);

  static const info = info600;

  // ── Transparent (black over white) ───────────────────────────────────
  static const transparent50 = Color(0x80000000);
  static const transparent30 = Color(0x4D000000);
  static const transparent20 = Color(0x33000000);
  static const transparent10 = Color(0x1A000000);

  // ── Other ────────────────────────────────────────────────────────────
  static const softGrey = Color(0xFFF4F4F4);
  static const lightGrey = Color(0xFFF9F9F9);
  static const stroke = Color(0xFFD9D9D9);

  static const white = Colors.white;
  static const black = Colors.black;
}

/// Brand semantic tokens. Screens and widgets should use these instead of
/// raw hex values.
class AppColors {
  final bool isDark;

  // brand
  final Color primary;
  final Color primaryHover;
  final Color onPrimary;

  // surfaces
  final Color background;
  final Color surface;
  final Color surfaceMuted;
  final Color surfaceElevated;

  // text
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color onDark;

  // strokes
  final Color border;
  final Color divider;

  // status
  final Color success;
  final Color successSoft;
  final Color danger;
  final Color dangerSoft;
  final Color info;
  final Color warning;

  // shadows
  final Color shadow;

  const AppColors._({
    required this.isDark,
    required this.primary,
    required this.primaryHover,
    required this.onPrimary,
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.surfaceElevated,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.onDark,
    required this.border,
    required this.divider,
    required this.success,
    required this.successSoft,
    required this.danger,
    required this.dangerSoft,
    required this.info,
    required this.warning,
    required this.shadow,
  });

  static const AppColors light = AppColors._(
    isDark: false,
    primary: AppPalette.primary500,
    primaryHover: AppPalette.primary600,
    onPrimary: AppPalette.secondary900,
    background: AppPalette.lightGrey,
    surface: AppPalette.white,
    surfaceMuted: AppPalette.lightGrey,
    surfaceElevated: AppPalette.white,
    textPrimary: AppPalette.secondary900,
    textSecondary: AppPalette.secondary500,
    textMuted: AppPalette.secondary400,
    onDark: AppPalette.white,
    border: AppPalette.stroke,
    divider: AppPalette.carbon100,
    success: AppPalette.success,
    successSoft: AppPalette.successSoft,
    danger: AppPalette.danger,
    dangerSoft: AppPalette.dangerSoft,
    info: AppPalette.info,
    warning: AppPalette.warning,
    shadow: Color(0x14121315),
  );

  static const AppColors dark = AppColors._(
    isDark: true,
    primary: AppPalette.primary400,
    primaryHover: AppPalette.primary200,
    onPrimary: AppPalette.secondary900,
    background: AppPalette.secondary900,
    surface: AppPalette.secondary800,
    surfaceMuted: AppPalette.carbon850,
    surfaceElevated: AppPalette.secondary700,
    textPrimary: Color(0xFFEDF1F7),
    textSecondary: AppPalette.secondary100,
    textMuted: AppPalette.secondary200,
    onDark: AppPalette.white,
    border: AppPalette.secondary600,
    divider: AppPalette.secondary700,
    success: AppPalette.success500,
    successSoft: AppPalette.success900,
    danger: AppPalette.error500,
    dangerSoft: AppPalette.error900,
    info: AppPalette.info400,
    warning: AppPalette.warning400,
    shadow: Color(0x66000000),
  );
}

/// Convenience extension so any widget can do `context.appColors`
/// to read the brand palette of the active theme.
extension AppColorsX on BuildContext {
  AppColors get appColors {
    final isDark = Theme.of(this).brightness == Brightness.dark;
    return isDark ? AppColors.dark : AppColors.light;
  }
}

abstract final class PartShopTheme {
  static ThemeData get light => _build(AppColors.light, Brightness.light);
  static ThemeData get dark => _build(AppColors.dark, Brightness.dark);

  static ThemeData _build(AppColors c, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final base = isDark
        ? ThemeData.dark(useMaterial3: true)
        : ThemeData.light(useMaterial3: true);

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: c.primary,
      onPrimary: c.onPrimary,
      primaryContainer:
          isDark ? AppPalette.secondary700 : AppPalette.primary100,
      onPrimaryContainer: isDark ? c.primary : AppPalette.primary700,
      secondary: c.textPrimary,
      onSecondary: c.surface,
      secondaryContainer: c.surfaceMuted,
      onSecondaryContainer: c.textPrimary,
      tertiary: c.danger,
      onTertiary: c.onDark,
      tertiaryContainer: c.dangerSoft,
      onTertiaryContainer: c.danger,
      error: c.danger,
      onError: c.onDark,
      errorContainer: c.dangerSoft,
      onErrorContainer: c.danger,
      surface: c.surface,
      onSurface: c.textPrimary,
      surfaceContainerHighest: c.surfaceMuted,
      onSurfaceVariant: c.textSecondary,
      outline: c.border,
      outlineVariant: c.divider,
      shadow: c.shadow,
      scrim: Colors.black54,
      inverseSurface: isDark ? c.surface : c.textPrimary,
      onInverseSurface: isDark ? c.textPrimary : c.surface,
      inversePrimary: c.primary,
    );

    final textTheme = base.textTheme.copyWith(
      displayLarge: base.textTheme.displayLarge?.copyWith(
        color: c.textPrimary,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      displayMedium: base.textTheme.displayMedium?.copyWith(
        color: c.textPrimary,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
      ),
      headlineLarge: base.textTheme.headlineLarge?.copyWith(
        color: c.textPrimary,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.3,
      ),
      headlineMedium: base.textTheme.headlineMedium?.copyWith(
        color: c.textPrimary,
        fontWeight: FontWeight.w800,
      ),
      headlineSmall: base.textTheme.headlineSmall?.copyWith(
        color: c.textPrimary,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: base.textTheme.titleLarge?.copyWith(
        color: c.textPrimary,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: base.textTheme.titleMedium?.copyWith(
        color: c.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: base.textTheme.titleSmall?.copyWith(
        color: c.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: base.textTheme.bodyLarge?.copyWith(color: c.textPrimary),
      bodyMedium: base.textTheme.bodyMedium?.copyWith(color: c.textPrimary),
      bodySmall: base.textTheme.bodySmall?.copyWith(color: c.textSecondary),
      labelLarge: base.textTheme.labelLarge?.copyWith(
        color: c.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: base.textTheme.labelMedium?.copyWith(color: c.textSecondary),
      labelSmall: base.textTheme.labelSmall?.copyWith(color: c.textMuted),
    );

    return base.copyWith(
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: c.background,
      canvasColor: c.background,
      dividerColor: c.divider,
      dividerTheme: DividerThemeData(color: c.divider, thickness: 1, space: 1),
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      iconTheme: IconThemeData(color: c.textPrimary, size: 22),
      primaryIconTheme: IconThemeData(color: c.textPrimary),
      appBarTheme: AppBarTheme(
        backgroundColor: c.background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: c.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle:
            textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        iconTheme: IconThemeData(color: c.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: c.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: c.border),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: c.surfaceMuted,
        selectedColor: c.primary,
        secondarySelectedColor: c.primary,
        labelStyle: textTheme.labelLarge,
        secondaryLabelStyle: textTheme.labelLarge?.copyWith(color: c.onPrimary),
        side: BorderSide(color: c.border),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: const StadiumBorder(),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.primary,
          foregroundColor: c.onPrimary,
          minimumSize: const Size(64, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.primary,
          foregroundColor: c.onPrimary,
          elevation: 0,
          minimumSize: const Size(64, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.textPrimary,
          minimumSize: const Size(64, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          side: BorderSide(color: c.border),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.primary,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: TextStyle(color: c.textMuted, fontWeight: FontWeight.w400),
        labelStyle: TextStyle(color: c.textSecondary),
        floatingLabelStyle:
            TextStyle(color: c.primary, fontWeight: FontWeight.w600),
        prefixIconColor: c.textSecondary,
        suffixIconColor: c.textSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: c.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: c.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: c.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: c.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: c.danger, width: 1.5),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: c.surface,
        elevation: 0,
        modalElevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.textPrimary,
        contentTextStyle:
            TextStyle(color: c.surface, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: c.surface,
        selectedItemColor: c.primary,
        unselectedItemColor: c.textMuted,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        elevation: 0,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: c.primary,
        foregroundColor: c.onPrimary,
        elevation: 6,
        shape: const CircleBorder(),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: c.textPrimary,
        unselectedLabelColor: c.textMuted,
        indicatorColor: c.primary,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
        dividerColor: Colors.transparent,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: c.primary),
      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return c.primary;
          return c.surfaceMuted;
        }),
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return c.onPrimary;
          return c.surface;
        }),
      ),
      splashFactory: NoSplash.splashFactory,
      highlightColor: c.primary.withValues(alpha: 0.06),
      hoverColor: c.primary.withValues(alpha: 0.04),
    );
  }
}
