import 'package:flutter/material.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.stepLabel,
    this.showLogo = true,
  });

  final String title;
  final String? subtitle;
  final String? stepLabel;
  final bool showLogo;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (stepLabel != null) ...[
          Text(
            stepLabel!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colors.textMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.m),
        ],
        if (showLogo) ...[
          Image.asset(
            'assets/images/logo.png',
            fit: BoxFit.cover,
            height: 100,
          ),
          const SizedBox(height: 10),
        ],
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.s),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.textMuted,
              height: 1.4,
            ),
          ),
        ],
        const SizedBox(height: 30),
      ],
    );
  }
}
