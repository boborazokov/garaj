import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';

class ActionCard extends StatelessWidget {
  final List<ProfileItem> items;
  final String? title;

  const ActionCard({super.key, required this.items, this.title});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              title!,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: colors.textMuted,
                    letterSpacing: 0.4,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: AppRadius.rL,
            border: Border.all(color: colors.border),
          ),
          child: Column(
            children: List.generate(items.length, (index) {
              final isLast = index == items.length - 1;
              return Column(
                children: [
                  items[index],
                  if (!isLast)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Divider(height: 1, color: colors.divider),
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

class ProfileItem extends StatelessWidget {
  final Icon iconPath;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool isDestructive;

  const ProfileItem({
    super.key,
    required this.iconPath,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = Theme.of(context);

    final iconColor = isDestructive ? colors.danger : colors.textPrimary;
    final iconBg = isDestructive
        ? colors.danger.withValues(alpha: 0.12)
        : colors.surfaceMuted;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: AppRadius.rS,
                ),
                child: IconTheme(
                  data: IconThemeData(color: iconColor, size: 18),
                  child: iconPath,
                ),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color:
                            isDestructive ? colors.danger : colors.textPrimary,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              trailing ??
                  Icon(LucideIcons.chevronRight,
                      size: 18, color: colors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
