import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:my_auto/core/provider/auth/auth.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/services/graphql/index.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/core/utils/resolve_media_url.dart';
import 'package:my_auto/widgets/image_cache/index.dart';
import 'package:provider/provider.dart';

class UserCard extends StatelessWidget {
  const UserCard({super.key});

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = Theme.of(context);
    final user = context.watch<AuthProvider>().auth!.user;
    final avatarUrl = resolveMediaUrl(user.image, mediaBase: fileUrl);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.primary, colors.primaryHover],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.rXl,
        boxShadow: AppShadows.glow(colors.primary),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
            ),
            clipBehavior: Clip.antiAlias,
            child: avatarUrl != null
                ? ImageCacheNetwork(
                    url: user.image!,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                  )
                : Center(
                    child: Text(
                      _initials(user.name),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: AppSpacing.l),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(LucideIcons.phone,
                        size: 14, color: Colors.white.withOpacity(0.9)),
                    const SizedBox(width: 6),
                    Text(
                      user.phone,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => context.push(RoutesName.editProfile),
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.4)),
              ),
              child: const Icon(LucideIcons.edit2,
                  size: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
