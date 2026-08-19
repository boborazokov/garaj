import 'api_error_code.dart';

/// Parsed API error from GraphQL extensions or REST JSON.
class ApiErrorPayload {
  const ApiErrorPayload({
    required this.code,
    this.debug,
    this.success = false,
  });

  final ApiErrorCode code;
  final String? debug;
  final bool success;

  factory ApiErrorPayload.fromExtensions(Map<String, dynamic>? extensions) {
    if (extensions == null) {
      return const ApiErrorPayload(code: ApiErrorCode.unknown);
    }
    final code =
        ApiErrorCode.tryParse(extensions['code']?.toString()) ??
        ApiErrorCode.unknown;
    return ApiErrorPayload(
      code: code,
      debug: extensions['debug']?.toString(),
      success: extensions['success'] == true,
    );
  }

  factory ApiErrorPayload.fromGraphqlMessage(String? message) {
    final code = ApiErrorCode.tryParse(message);
    if (code != null) {
      return ApiErrorPayload(code: code);
    }
    return ApiErrorPayload(
      code: ApiErrorCode.unknown,
      debug: message,
    );
  }
}
