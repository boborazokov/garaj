import 'package:flutter/widgets.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:my_auto/widgets/toaster/index.dart';

import 'graphql_error_ui.dart';

/// When to show API errors to the user.
///
/// - [userAction] — user tapped Submit / Save / Login → show toast if failed.
/// - [background] — feed load, map, subscriptions → never toast (inline UI only).
enum ErrorPresentation {
  userAction,
  background,
}

/// Central gate for user-visible error toasts.
class UserFacingErrors {
  UserFacingErrors._();

  static void show(
    BuildContext context, {
    required ErrorPresentation presentation,
    OperationException? exception,
    QueryResult? result,
    String? fallback,
  }) {
    if (presentation == ErrorPresentation.background) {
      assert(() {
        debugPrint('[UserFacingErrors] suppressed background: $exception');
        return true;
      }());
      return;
    }

    if (result != null && result.hasException) {
      GraphqlErrorUi.showToastFromResult(context, result);
      return;
    }
    if (exception != null) {
      GraphqlErrorUi.showToast(context, exception);
      return;
    }
    if (fallback != null && fallback.isNotEmpty) {
      Toaster.error(fallback, context: context);
    }
  }
}
