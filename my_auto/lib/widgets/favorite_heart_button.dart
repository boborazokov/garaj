import 'package:flutter/material.dart';
import 'package:my_auto/core/auth/auth_guard.dart';
import 'package:my_auto/core/auth/pending_action.dart';
import 'package:my_auto/core/provider/home/setFavorite/index.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:provider/provider.dart';

/// Heart toggle with contrast on light/dark cards and photos.
class FavoriteHeartButton extends StatelessWidget {
  const FavoriteHeartButton({
    super.key,
    required this.partId,
    this.serviceId,
    this.size = 18,
    this.padding = 7,
    this.onLightImage = true,
  });

  final String partId;
  final String? serviceId;
  final double size;
  final double padding;
  final bool onLightImage;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<SetFavoriteProvider>(
      builder: (context, fav, _) {
        final isFav = fav.isFavorite(partId);
        final bg = onLightImage
            ? (isDark
                ? Colors.black.withValues(alpha: 0.55)
                : Colors.white.withValues(alpha: 0.94))
            : (isDark
                ? colors.surfaceMuted
                : colors.surface.withValues(alpha: 0.96));

        final iconColor = isFav
            ? colors.danger
            : (onLightImage
                ? (isDark ? Colors.white : colors.textPrimary)
                : (isDark ? Colors.white : colors.textPrimary));

        return Material(
          color: bg,
          shape: const CircleBorder(),
          elevation: onLightImage ? 2 : 0,
          shadowColor: Colors.black26,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () async {
              final ok = await AuthGuard.requireAuth(
                context,
                pending: PendingToggleFavorite(
                  partId: partId,
                  serviceId: serviceId,
                ),
              );
              if (!ok || !context.mounted) return;
              if (AuthGuard.isAuthenticated(context)) {
                fav.toggleFavoriteDebounced(serviceId, partId);
              }
            },
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: Icon(
                isFav ? Icons.favorite : Icons.favorite_border,
                size: size,
                color: iconColor,
              ),
            ),
          ),
        );
      },
    );
  }
}
