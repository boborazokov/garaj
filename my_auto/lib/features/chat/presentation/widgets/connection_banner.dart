import 'package:flutter/material.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/core/theme/colors/index.dart';

class ConnectionBanner extends StatelessWidget {
  const ConnectionBanner({
    super.key,
    required this.alive,
    this.onRetry,
  });

  final bool alive;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    if (alive) return const SizedBox.shrink();
    final colors = context.appColors;
    return Material(
      color: colors.warning.withValues(alpha: 0.15),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(Icons.cloud_off, size: 18, color: colors.warning),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                S.of(context).chatReconnecting,
                style: TextStyle(
                  color: colors.warning,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
            if (onRetry != null)
              TextButton(
                onPressed: onRetry,
                child: Text(S.of(context).createProductRetry),
              ),
          ],
        ),
      ),
    );
  }
}
