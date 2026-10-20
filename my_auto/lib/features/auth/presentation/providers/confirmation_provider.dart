import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:my_auto/core/auth/pending_action_manager.dart';
import 'package:my_auto/core/auth/pending_signup_token.dart';
import 'package:my_auto/core/model/user/index.dart';
import 'package:my_auto/core/provider/auth/auth.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/services/graphql/index.dart';
import 'package:my_auto/features/auth/data/api/auth_api.dart';
import 'package:my_auto/features/auth/presentation/controllers/confirmation_controller.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/core/errors/user_facing_errors.dart';
import 'package:my_auto/widgets/toaster/index.dart';
import 'package:provider/provider.dart';

class ConfirmationProvider extends ChangeNotifier {
  final ConfirmationController controller = ConfirmationController();
  bool isLoading = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> confirmCode(BuildContext context, String signupToken) async {
    if (isLoading) return;

    var token = signupToken.trim();
    if (token.isEmpty || token.split('.').length != 3) {
      final cached = (await readPendingSignupToken())?.trim() ?? '';
      if (cached.isNotEmpty && cached.split('.').length == 3) {
        token = cached;
      }
    }
    if (token.isEmpty || token.split('.').length != 3) {
      if (context.mounted) {
        Toaster.error(S.of(context).invalidOtpCode);
      }
      return;
    }

    final code = controller.codeController.text.trim();
    if (code.length != 5) {
      Toaster.error(S.of(context).confirmationCodeNeedsToBe5Symbols);
      return;
    }

    isLoading = true;
    notifyListeners();

    if (kDebugMode) {
      debugPrint(
        '[Confirmation] tokenLen=${token.length} codeLen=${code.length}',
      );
    }

    try {
      await context.read<AuthProvider>().clearOrphanBearerIfGuest();

      final result = await GraphQLConfig.client().mutate(
        MutationOptions(
          document: gql(confirmSignUpMutation),
          operationName: 'ConfirmSignUp',
          variables: {'token': token, 'code': code},
          fetchPolicy: FetchPolicy.noCache,
        ),
      );

      final confirmPayload = result.data?['confirmSignUp'];
      if (confirmPayload == null) {
        if (result.hasException && context.mounted) {
          UserFacingErrors.show(
            context,
            presentation: ErrorPresentation.userAction,
            result: result,
          );
        }
        return;
      }

      {
        final authData = AuthOutput.fromJson(
          Map<String, dynamic>.from(confirmPayload as Map),
        );
        await clearPendingSignupToken();
        await context.read<AuthProvider>().setAuth(authData);
        if (!context.mounted) return;
        // Clear confirmation / signup from the stack.
        context.go(RoutesName.buttonNavigationBar);
        await Future<void>.delayed(Duration.zero);
        if (!context.mounted) return;
        await PendingActionManager.instance.replay(context);
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
