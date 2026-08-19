import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_auto/core/auth/auth_wall_sheet.dart';
import 'package:my_auto/core/auth/pending_action.dart';
import 'package:my_auto/core/auth/pending_action_manager.dart';
import 'package:my_auto/core/provider/auth/auth.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:provider/provider.dart';

/// Guest-first auth helpers. Never blocks browsing — only gates protected
/// mutations and screens.
class AuthGuard {
  AuthGuard._();

  /// Returns `true` when the user is already signed in.
  ///
  /// For guests: stores [pending], shows the auth bottom sheet, and on
  /// "Sign in" navigates to [/signin]. Replay happens after login in
  /// [SigninProvider] / [ConfirmationProvider].
  static Future<bool> requireAuth(
    BuildContext context, {
    PendingAction? pending,
    String? title,
    String? message,
  }) async {
    if (context.read<AuthProvider>().isAuthenticated) return true;

    if (pending != null) {
      PendingActionManager.instance.set(pending);
    }

    final wantsSignIn = await showAuthWallSheet(
      context,
      title: title,
      message: message,
    );
    if (!wantsSignIn || !context.mounted) return false;

    context.push(RoutesName.signin);
    return false;
  }

  static bool isAuthenticated(BuildContext context) =>
      context.read<AuthProvider>().isAuthenticated;
}
