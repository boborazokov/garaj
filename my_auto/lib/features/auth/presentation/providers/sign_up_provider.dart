import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:my_auto/core/auth/pending_signup_token.dart';
import 'package:my_auto/core/errors/user_facing_errors.dart';
import 'package:my_auto/core/provider/auth/auth.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/services/graphql/index.dart';
import 'package:my_auto/core/utils/phoneFormater.dart';
import 'package:my_auto/features/auth/data/api/auth_api.dart';
import 'package:my_auto/features/auth/presentation/controllers/sign_up_controller.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/toaster/index.dart';
import 'package:provider/provider.dart';

class SignUpProvider extends ChangeNotifier {
  final SignUpController controller = SignUpController();
  bool isLoading = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> signUp(BuildContext context) async {
    if (isLoading) return;
    if (!controller.validateForm()) return;

    isLoading = true;
    notifyListeners();

    try {
      await context.read<AuthProvider>().clearOrphanBearerIfGuest();

      final result = await GraphQLConfig.client().mutate(
        MutationOptions(
          document: gql(signUpMutation),
          operationName: 'SignUp',
          variables: {
            'data': {
              'name': controller.nameController.text.trim(),
              'phone': UzbekPhone.normalize(controller.phoneController.text),
              'password': controller.passwordController.text,
            },
          },
          fetchPolicy: FetchPolicy.noCache,
        ),
      );

      if (!context.mounted) return;

      final data = result.data;
      final rawToken = data?['signUp']?['token'];
      if (rawToken == null) {
        if (result.hasException) {
          UserFacingErrors.show(
            context,
            presentation: ErrorPresentation.userAction,
            result: result,
          );
        } else {
          Toaster.error(S.of(context).serverNotWorking);
        }
        return;
      }

      final token = rawToken is String ? rawToken.trim() : '';

      if (token.isEmpty || token.split('.').length != 3) {
        if (kDebugMode) {
          debugPrint('[SignUp] invalid signup token: "$rawToken"');
        }
        Toaster.error(S.of(context).serverNotWorking);
        return;
      }

      await savePendingSignupToken(token);
      if (!context.mounted) return;
      context.go(
        RoutesName.confirmation,
        extra: <String, dynamic>{
          'token': token,
        },
      );
    } catch (_) {
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
