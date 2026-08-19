import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:my_auto/core/auth/pending_action_manager.dart';
import 'package:my_auto/core/provider/auth/auth.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/provider/language/index.dart';
import 'package:my_auto/core/provider/theme/index.dart';
import 'package:my_auto/core/layout/app_safe_area.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:provider/provider.dart';

void logOut(BuildContext context) {
  final authProvider = context.read<AuthProvider>();
  final colors = context.appColors;
  final s = S.of(context);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetCtx) => Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        stickyBottomPadding(sheetCtx, homeExtra: 24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: colors.border,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: colors.danger.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(LucideIcons.logOut, size: 30, color: colors.danger),
          ),
          const SizedBox(height: 16),
          Text(
            s.logoutDescription,
            textAlign: TextAlign.center,
            style: Theme.of(sheetCtx).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            s.logoutSubtitle,
            textAlign: TextAlign.center,
            style: Theme.of(sheetCtx).textTheme.bodyMedium?.copyWith(
                  color: colors.textMuted,
                ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(sheetCtx),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    side: BorderSide(color: colors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.rM,
                    ),
                  ),
                  child: Text(s.cancel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(sheetCtx);
                    await authProvider.logout();
                    PendingActionManager.instance.clear();
                    if (!context.mounted) return;
                    await context.read<LocaleNotifier>().loadLocale();
                    if (!context.mounted) return;
                    await context.read<ThemeProvider>().reloadFromPrefs();
                    if (!context.mounted) return;
                    context.go(RoutesName.buttonNavigationBar);
                  },
                  icon: const Icon(LucideIcons.logOut, size: 18),
                  label: Text(s.logout),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.danger,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.rM,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
