import 'package:flutter/material.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/widgets/brand_logo.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.stepLabel,
    this.showLogo = true,
    /// Smaller logo + tighter gaps — use on multi-field screens (sign up).
    this.compact = false,
  });

  final String title;
  final String? subtitle;
  final String? stepLabel;
  final bool showLogo;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;
    final logoWidth = compact ? 168.0 : 200.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (stepLabel != null) ...[
          Text(
            stepLabel!,
            textAlign: TextAlign.center,
            style: textTheme.labelMedium?.copyWith(
              color: colors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.s),
        ],
        if (showLogo) ...[
          Center(child: BrandLogo(width: logoWidth)),
          SizedBox(height: compact ? AppSpacing.m : AppSpacing.l),
        ],
        Text(
          title,
          textAlign: TextAlign.center,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            height: 1.2,
            color: colors.textPrimary,
            fontSize: compact ? 20 : 22,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.s),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: colors.textSecondary,
              height: 1.35,
              fontSize: 13,
            ),
          ),
        ],
        SizedBox(height: compact ? AppSpacing.l : AppSpacing.xl),
      ],
    );
  }
}
