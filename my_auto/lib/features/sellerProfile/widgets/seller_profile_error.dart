import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:my_auto/core/errors/graphql_error_ui.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/generated/l10n.dart';

class SellerProfileError extends StatelessWidget {
  final Object? error;
  final VoidCallback onRetry;

  const SellerProfileError({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    final message = GraphqlErrorUi.localizeThrowable(context, error);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.store, size: 48, color: colors.textMuted),
            const SizedBox(height: 16),
            Text(
              s.unableToLoadStore,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textMuted),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(LucideIcons.refreshCw, size: 18),
              label: Text(s.retry),
            ),
          ],
        ),
      ),
    );
  }
}
