import 'package:flutter/material.dart';

import 'app_safe_area.dart';

/// Sticky bottom actions above the keyboard and system gesture/home bar.
///
/// Does **not** wrap [child] in [SafeArea] — bottom insets are applied once via
/// [padding] to avoid doubling with [MediaQuery.padding].
class BottomSafeButton extends StatelessWidget {
  const BottomSafeButton({
    super.key,
    required this.child,
    this.backgroundColor,
    this.elevation = 12,
    this.padding,
  });

  final Widget child;
  final Color? backgroundColor;
  final double elevation;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final bottomPad = stickyBottomPadding(context);

    final bg = backgroundColor ??
        Theme.of(context).colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.94,
            );

    return Material(
      elevation: elevation,
      color: Colors.transparent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        decoration: BoxDecoration(color: bg),
        padding: padding ?? EdgeInsets.fromLTRB(16, 12, 16, bottomPad),
        child: child,
      ),
    );
  }
}
