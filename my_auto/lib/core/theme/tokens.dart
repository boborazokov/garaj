import 'package:flutter/material.dart';

import 'package:my_auto/core/theme/colors/index.dart';

/// Spacing scale used across the entire app.
class AppSpacing {
  AppSpacing._();
  static const double xxs = 2;
  static const double xs = 4;
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 40;
  static const double screenPadding = 16;
}

/// Corner radius scale.
class AppRadius {
  AppRadius._();
  static const double xs = 6;
  static const double s = 10;
  static const double m = 14;
  static const double l = 18;
  static const double xl = 24;
  static const double pill = 999;

  static BorderRadius get rXs => BorderRadius.circular(xs);
  static BorderRadius get rS => BorderRadius.circular(s);
  static BorderRadius get rM => BorderRadius.circular(m);
  static BorderRadius get rL => BorderRadius.circular(l);
  static BorderRadius get rXl => BorderRadius.circular(xl);
}

/// Animation durations.
class AppMotion {
  AppMotion._();
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration base = Duration(milliseconds: 240);
  static const Duration slow = Duration(milliseconds: 380);
  static const Curve standard = Curves.easeOutCubic;
  static const Curve emphasized = Curves.easeOutBack;
}

/// Soft, layered shadows tuned for the Amber & Carbon palette.
class AppShadows {
  AppShadows._();

  static List<BoxShadow> card(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return const [
        BoxShadow(
          color: Color(0x66000000),
          blurRadius: 20,
          offset: Offset(0, 8),
        ),
      ];
    }
    return const [
      BoxShadow(
        color: Color(0x0F0B0F14),
        blurRadius: 18,
        offset: Offset(0, 6),
      ),
      BoxShadow(
        color: Color(0x080B0F14),
        blurRadius: 4,
        offset: Offset(0, 1),
      ),
    ];
  }

  static List<BoxShadow> floating(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return const [
        BoxShadow(
          color: Color(0x99000000),
          blurRadius: 28,
          offset: Offset(0, 12),
        ),
      ];
    }
    return const [
      BoxShadow(
        color: Color(0x14000000),
        blurRadius: 28,
        offset: Offset(0, 14),
      ),
    ];
  }

  static List<BoxShadow> glow(Color color) {
    return [
      BoxShadow(
        color: color.withOpacity(0.35),
        blurRadius: 24,
        offset: const Offset(0, 8),
      ),
    ];
  }
}

/// Convenience helper for reading semantic colors anywhere via
/// `context.appColors`. Defined in `colors/index.dart`.
typedef AppColorsExt = AppColors;
