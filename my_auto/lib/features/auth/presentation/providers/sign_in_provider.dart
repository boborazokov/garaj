import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:my_auto/core/auth/pending_action_manager.dart';
import 'package:my_auto/core/model/user/index.dart';
import 'package:my_auto/core/provider/auth/auth.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/services/graphql/index.dart';
import 'package:my_auto/features/auth/data/api/auth_api.dart';
import 'package:my_auto/features/auth/presentation/controllers/sign_in_controller.dart';
import 'package:my_auto/core/errors/user_facing_errors.dart';
import 'package:provider/provider.dart';

class SignInProvider extends ChangeNotifier {
  final SignInController controller = SignInController();
  bool isLoading = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> signIn(BuildContext context) async {
    isLoading = true;
    notifyListeners();

    try {
      await context.read<AuthProvider>().clearOrphanBearerIfGuest();

      final result = await GraphQLConfig.client().query(
        QueryOptions(
          document: gql(signInQuery),
          operationName: 'SignIn',
          variables: {
            'data': {
              'phone': controller.phoneController.text
                  .replaceAll(RegExp(r'[^+0-9]'), ''),
              'password': controller.passwordController.text,
            },
          },
          fetchPolicy: FetchPolicy.noCache,
        ),
      );

      final signInPayload = result.data?['signIn'];
      if (signInPayload == null) {
        if (result.hasException && context.mounted) {
          UserFacingErrors.show(
            context,
            presentation: ErrorPresentation.userAction,
            result: result,
          );
        }
        return;
      }

      final authData = AuthOutput.fromJson(
        Map<String, dynamic>.from(signInPayload as Map),
      );
      await context.read<AuthProvider>().setAuth(authData);
      controller.clearForm();
      if (!context.mounted) return;
      // Clear sign-in from the stack so Back from create-product ≠ login.
      context.go(RoutesName.buttonNavigationBar);
      await Future<void>.delayed(Duration.zero);
      if (!context.mounted) return;
      await PendingActionManager.instance.replay(context);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
