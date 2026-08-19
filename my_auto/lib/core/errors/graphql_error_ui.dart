import 'package:flutter/widgets.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/toaster/index.dart';

import 'api_error_code.dart';
import 'api_error_mapper.dart';
import 'api_error_payload.dart';

/// User-facing GraphQL error text and toasts (never raw backend codes).
class GraphqlErrorUi {
  GraphqlErrorUi._();

  static String localize(BuildContext context, OperationException? exception) {
    return ApiErrorMapper.messageFromException(context, exception);
  }

  static String localizeFromResult(BuildContext context, QueryResult result) {
    if (!result.hasException) return '';
    return localize(context, result.exception);
  }

  /// Maps stored failure message (wire code or legacy English) to UI string.
  static String localizeRaw(BuildContext context, String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return S.of(context).errorGeneric;
    }
    final code = ApiErrorCode.tryParse(raw);
    if (code != null) {
      return ApiErrorMapper.localize(context, ApiErrorPayload(code: code));
    }
    for (final c in ApiErrorCode.values) {
      if (c == ApiErrorCode.unknown) continue;
      if (raw.contains(c.wireValue)) {
        return ApiErrorMapper.localize(context, ApiErrorPayload(code: c));
      }
    }
    return S.of(context).errorGeneric;
  }

  /// [OperationException], wire codes in [Object.toString], or generic fallback.
  static String localizeThrowable(BuildContext context, Object? error) {
    if (error is OperationException) {
      return localize(context, error);
    }
    if (error is String) return localizeRaw(context, error);
    return localizeRaw(context, error?.toString());
  }

  static void showToast(BuildContext context, OperationException? exception) {
    Toaster.error(localize(context, exception));
  }

  static void showToastFromResult(BuildContext context, QueryResult result) {
    if (!result.hasException) return;
    showToast(context, result.exception);
  }
}
