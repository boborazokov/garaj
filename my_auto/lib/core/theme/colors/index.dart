import 'package:flutter/material.dart';

/// Garage "primary & Carbon" palette.
///
/// Brand identity: a marketplace for car spare parts and announcements.
/// primary (#F59E0B) — premium automotive feel, warm and high-contrast.
/// Carbon (#0B0F14) — deep neutral with a slightly cool tint, like
/// matte-finished engine bay panels.
class AppPalette {
  AppPalette._();

  static const primary100 = Color(0xFFD0F2D3);
  static const primary200 = Color(0xFFB9ECBD);
  static const primary300 = Color(0xFF99E39F);
  static const primary400 = Color(0xFF85DD8D);
  static const primary500 = Color(0xFF67D570);
  static const primary600 = Color(0xFF5EC266);
  static const primary700 = Color(0xFF499750);
  static const primary800 = Color(0xFF39753E);
  static const primary900 = Color(0xFF2B592F);

  static const carbon900 = Color(0xFF0B0F14);
  static const carbon850 = Color(0xFF11161D);
  static const carbon800 = Color(0xFF141A22);
  static const carbon700 = Color(0xFF1C2430);
  static const carbon600 = Color(0xFF2A3441);
  static const carbon500 = Color(0xFF3A4554);
  static const carbon400 = Color(0xFF566374);
  static const carbon300 = Color(0xFF8B97A8);
  static const carbon200 = Color(0xFFB8C2D0);
  static const carbon100 = Color(0xFFE5E9EF);
  static const carbon50 = Color(0xFFF4F6FA);

  static const success = Color(0xFF088B3A);
  static const successSoft = Color(0xFFDAF3E4);
  static const danger = Color(0xFFC93C32);
  static const dangerSoft = Color(0xFFFBE8D8);
  static const info = Color(0xFF0079E8);
  static const warning = Color(0xFFFFD800);

  static const white = Colors.white;
  static const black = Colors.black;
}

/// Brand semantic tokens. These are the canonical colors that screens
/// and components should reference instead of literal hex codes.
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
    onPrimary: AppPalette.carbon900,
    background: AppPalette.carbon50,
    surface: AppPalette.white,
    surfaceMuted: Color(0xFFF1F3F8),
    surfaceElevated: AppPalette.white,
    textPrimary: AppPalette.carbon900,
    textSecondary: AppPalette.carbon500,
    textMuted: AppPalette.carbon400,
    onDark: AppPalette.white,
    border: AppPalette.carbon100,
    divider: Color(0xFFEAEDF3),
    success: AppPalette.success,
    successSoft: AppPalette.successSoft,
    danger: AppPalette.danger,
    dangerSoft: AppPalette.dangerSoft,
    info: AppPalette.info,
    warning: AppPalette.warning,
    shadow: Color(0x140B0F14),
  );

  static const AppColors dark = AppColors._(
    isDark: true,
    primary: AppPalette.primary400,
    primaryHover: AppPalette.primary200,
    onPrimary: AppPalette.carbon900,
    background: AppPalette.carbon900,
    surface: AppPalette.carbon800,
    surfaceMuted: AppPalette.carbon850,
    surfaceElevated: AppPalette.carbon700,
    textPrimary: Color(0xFFEDF1F7),
    textSecondary: AppPalette.carbon200,
    textMuted: AppPalette.carbon300,
    onDark: AppPalette.white,
    border: AppPalette.carbon600,
    divider: AppPalette.carbon700,
    success: AppPalette.success,
    successSoft: Color(0xFF14532D),
    danger: AppPalette.danger,
    dangerSoft: Color(0xFF7F1D1D),
    info: AppPalette.info,
    warning: AppPalette.primary400,
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
      primaryContainer: isDark ? AppPalette.carbon700 : AppPalette.primary100,
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
      highlightColor: c.primary.withOpacity(0.06),
      hoverColor: c.primary.withOpacity(0.04),
    );
  }
}
