import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:my_auto/core/auth/pending_action_manager.dart';
import 'package:my_auto/core/errors/user_facing_errors.dart';
import 'package:my_auto/core/model/user/index.dart';
import 'package:my_auto/core/provider/auth/auth.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/services/graphql/index.dart';
import 'package:my_auto/core/utils/phoneFormater.dart';
import 'package:my_auto/features/auth/data/api/auth_api.dart';
import 'package:my_auto/features/auth/presentation/controllers/sign_in_controller.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/toaster/index.dart';
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
    if (isLoading) return;
    if (!controller.validateForm()) return;

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
              'phone': UzbekPhone.normalize(controller.phoneController.text),
              'password': controller.passwordController.text,
            },
          },
          fetchPolicy: FetchPolicy.noCache,
        ),
      );

      if (!context.mounted) return;

      final signInPayload = result.data?['signIn'];
      if (signInPayload == null) {
        if (result.hasException) {
          UserFacingErrors.show(
            context,
            presentation: ErrorPresentation.userAction,
            result: result,
          );
        } else {
          Toaster.error(S.of(context).errorAuthInvalidCredentials);
        }
        return;
      }

      final authData = AuthOutput.fromJson(
        Map<String, dynamic>.from(signInPayload as Map),
      );
      await context.read<AuthProvider>().setAuth(authData);
      controller.clearForm();
      if (!context.mounted) return;
      context.go(RoutesName.buttonNavigationBar);
      await Future<void>.delayed(Duration.zero);
      if (!context.mounted) return;
      await PendingActionManager.instance.replay(context);
    } catch (e) {
      if (context.mounted) {
        UserFacingErrors.show(
          context,
          presentation: ErrorPresentation.userAction,
          fallback: S.of(context).errorGeneric,
        );
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
