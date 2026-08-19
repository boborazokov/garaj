import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Bottom inset for home indicator / 3-button nav.
///
/// On edge-to-edge Android, [MediaQuery.padding] can be zero while
/// [MediaQuery.viewPadding] still reports the system bar height.
double systemBottomInset(BuildContext context) {
  final mq = MediaQuery.of(context);
  return math.max(mq.padding.bottom, mq.viewPadding.bottom);
}

/// [base] plus [systemBottomInset] — for [Positioned] `bottom:` values.
double bottomSafeOffset(BuildContext context, double base) =>
    base + systemBottomInset(context);

/// Top inset (status bar / notch), including edge-to-edge Android.
double systemTopInset(BuildContext context) {
  final mq = MediaQuery.of(context);
  return math.max(mq.padding.top, mq.viewPadding.top);
}

/// Scroll padding above a docked bottom nav (~96 logical px) + system inset.
double listPaddingAboveBottomNav(
  BuildContext context, {
  double navBarHeight = 96,
}) =>
    navBarHeight + systemBottomInset(context);

/// Bottom padding for sticky bars / sheets: lifts with keyboard, else system nav.
double stickyBottomPadding(
  BuildContext context, {
  double keyboardExtra = 12,
  double homeExtra = 16,
}) {
  final kb = MediaQuery.viewInsetsOf(context).bottom;
  if (kb > 0) return kb + keyboardExtra;
  return systemBottomInset(context) + homeExtra;
}

/// Default safe area for screens: respects notch, Dynamic Island,
/// gesture nav indicators, camera cutouts.
///
/// Prefer this over raw [SafeArea] so we can tweak [minimum] in one place.
class AppSafeArea extends StatelessWidget {
  const AppSafeArea({
    super.key,
    required this.child,
    this.top = true,
    this.bottom = true,
    this.left = true,
    this.right = true,
    this.minimum = EdgeInsets.zero,
  });

  final Widget child;
  final bool top;
  final bool bottom;
  final bool left;
  final bool right;
  final EdgeInsets minimum;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final insets = minimum +
        EdgeInsets.only(
          top: top ? systemTopInset(context) : 0,
          bottom: bottom ? systemBottomInset(context) : 0,
          left: left ? math.max(mq.padding.left, mq.viewPadding.left) : 0,
          right: right ? math.max(mq.padding.right, mq.viewPadding.right) : 0,
        );
    if (insets == EdgeInsets.zero) return child;
    return Padding(padding: insets, child: child);
  }
}
