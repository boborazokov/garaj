import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/generated/l10n.dart';

class AuthTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AuthTopBar({super.key, this.showSkip = true});

  final bool showSkip;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      actions: [
        if (showSkip)
          Padding(
            padding: const EdgeInsetsDirectional.only(end: AppSpacing.s),
            child: TextButton(
              onPressed: () => context.go(RoutesName.buttonNavigationBar),
              style: TextButton.styleFrom(
                minimumSize: const Size(48, 44),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.m,
                  vertical: AppSpacing.s,
                ),
                foregroundColor: colors.textSecondary,
              ),
              child: Text(
                S.of(context).skip,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
      ],
    );
  }
}
