import 'package:flutter/material.dart';

/// Breakpoints and helpers for chat layouts (mobile vs web/desktop).
abstract final class ChatResponsive {
  static const double wideBreakpoint = 900;
  static const double sidebarWidth = 380;
  static const double messageColumnMaxWidth = 760;

  static bool isWide(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= wideBreakpoint;

  static double bubbleMaxWidth(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (isWide(context)) {
      return (messageColumnMaxWidth * 0.62).clamp(280.0, 480.0);
    }
    return w * 0.74;
  }
}
