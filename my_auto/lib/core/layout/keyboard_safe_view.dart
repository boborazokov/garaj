import 'package:flutter/material.dart';

/// Keeps scrollable/layout content readable when the software keyboard opens.
/// Wrap screens that contain text fields — especially inside [CustomScrollView].
class KeyboardSafeView extends StatelessWidget {
  const KeyboardSafeView({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 180),
    this.curve = Curves.easeOutCubic,
  });

  final Widget child;
  final Duration duration;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return AnimatedPadding(
      duration: duration,
      curve: curve,
      padding: EdgeInsets.only(bottom: bottom),
      child: child,
    );
  }
}
