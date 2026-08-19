import 'package:flutter/material.dart';

import 'package:my_auto/core/layout/layout.dart';
import 'package:my_auto/core/theme/colors/index.dart';

/// Standard UX for screens backed by remote data: loading, error+retry,
/// optional empty state, success [child].
///
/// Prefer this over ad-hoc [Center CircularProgressIndicator] /
/// bare [Text] errors for consistency across the app.
class AsyncContent extends StatelessWidget {
  const AsyncContent({
    super.key,
    required this.isLoading,
    this.errorMessage,
    this.onRetry,
    this.showEmptyWhen = false,
    this.empty,
    required this.loading,
    required this.child,
    this.keyboardSafe = false,
    this.padChild = EdgeInsets.zero,
  });

  final bool isLoading;
  final String? errorMessage;

  /// If non-null while not loading → error panel is shown.
  final VoidCallback? onRetry;
  final bool showEmptyWhen;
  final Widget? empty;

  /// Shown instead of generic spinner during load (e.g. shimmer skeleton).
  final Widget loading;

  /// Main content — only shown when loading is false and no blocking error.
  final Widget child;
  final bool keyboardSafe;
  final EdgeInsetsGeometry padChild;

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (isLoading) {
      body = loading;
    } else if (errorMessage != null && errorMessage!.isNotEmpty) {
      body = AsyncErrorPane(
        message: errorMessage!,
        onRetry: onRetry,
      );
    } else if (showEmptyWhen) {
      body = empty ?? const AsyncEmptyPane();
    } else {
      body = Padding(padding: padChild, child: child);
    }

    if (keyboardSafe) {
      return KeyboardSafeView(child: body);
    }
    return body;
  }
}

class AsyncErrorPane extends StatelessWidget {
  const AsyncErrorPane({
    super.key,
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: colors.danger),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textSecondary, height: 1.4),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              FilledButton(
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AsyncEmptyPane extends StatelessWidget {
  const AsyncEmptyPane({
    super.key,
    this.icon = Icons.inbox_outlined,
    this.title,
    this.subtitle,
  });

  final IconData icon;
  final String? title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: colors.textMuted),
            const SizedBox(height: 12),
            if (title != null)
              Text(
                title!,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.textMuted, height: 1.35),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
