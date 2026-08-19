import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/theme/colors/index.dart';
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
      actions: [
        if (showSkip)
          TextButton(
            onPressed: () => context.go(RoutesName.buttonNavigationBar),
            child: Text(
              S.of(context).skip,
              style: TextStyle(
                color: colors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}
