import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:my_auto/core/auth/pending_action_manager.dart';
import 'package:my_auto/core/provider/auth/auth.dart';
import 'package:my_auto/core/provider/language/index.dart';
import 'package:my_auto/core/provider/theme/index.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/layout/app_safe_area.dart';
import 'package:my_auto/core/services/graphql/index.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/features/profile/api/delete_account_api.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:provider/provider.dart';

void deleteAccount(BuildContext context) {
  final authProvider = context.read<AuthProvider>();
  final colors = context.appColors;
  final s = S.of(context);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetCtx) => _DeleteAccountSheet(
      colors: colors,
      s: s,
      onConfirm: () async {
        Navigator.pop(sheetCtx);
        final messenger = ScaffoldMessenger.of(context);
        final success = await _runDeleteAccount(authProvider);
        if (!context.mounted) return;
        if (success) {
          messenger.showSnackBar(
            SnackBar(content: Text(s.deleteAccountSuccess)),
          );
          PendingActionManager.instance.clear();
          await context.read<LocaleNotifier>().loadLocale();
          if (!context.mounted) return;
          await context.read<ThemeProvider>().reloadFromPrefs();
          if (!context.mounted) return;
          context.go(RoutesName.buttonNavigationBar);
        } else {
          messenger.showSnackBar(
            SnackBar(content: Text(s.deleteAccountFailed)),
          );
        }
      },
    ),
  );
}

Future<bool> _runDeleteAccount(AuthProvider authProvider) async {
  try {
    final result = await GraphQLConfig.client().mutate(
      MutationOptions(document: gql(DELETE_MY_ACCOUNT)),
    );
    if (result.hasException) return false;
    final payload = result.data?['deleteMyAccount'];
    if (payload is! Map || payload['success'] != true) return false;
    await authProvider.logout();
    return true;
  } catch (_) {
    return false;
  }
}

class _DeleteAccountSheet extends StatelessWidget {
  const _DeleteAccountSheet({
    required this.colors,
    required this.s,
    required this.onConfirm,
  });

  final AppColors colors;
  final S s;
  final Future<void> Function() onConfirm;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        stickyBottomPadding(context, homeExtra: 24),
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
            child: Icon(LucideIcons.userX, size: 30, color: colors.danger),
          ),
          const SizedBox(height: 16),
          Text(
            s.deleteAccountDescription,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            s.deleteAccountSubtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.textMuted,
                ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
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
                  onPressed: onConfirm,
                  icon: const Icon(LucideIcons.trash2, size: 18),
                  label: Text(s.deleteAccountConfirm),
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
    );
  }
}
