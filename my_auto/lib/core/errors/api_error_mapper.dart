import 'package:flutter/widgets.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:my_auto/generated/l10n.dart';

import 'api_error_code.dart';
import 'api_error_payload.dart';

/// Maps backend error codes to localized user-facing strings.
class ApiErrorMapper {
  ApiErrorMapper._();

  static String localize(BuildContext context, ApiErrorPayload error) {
    final s = S.of(context);
    switch (error.code) {
      case ApiErrorCode.authUnauthorized:
        return s.errorAuthUnauthorized;
      case ApiErrorCode.authForbidden:
        return s.errorAuthForbidden;
      case ApiErrorCode.authUserExists:
        return s.errorAuthUserExists;
      case ApiErrorCode.authUserNotFound:
        return s.errorAuthUserNotFound;
      case ApiErrorCode.authInvalidCredentials:
        return s.errorAuthInvalidCredentials;
      case ApiErrorCode.authInvalidOtp:
        return s.errorAuthInvalidOtp;
      case ApiErrorCode.authOtpExpired:
        return s.errorAuthOtpExpired;
      case ApiErrorCode.authConfirmationTokenMissing:
        return s.errorAuthConfirmationTokenMissing;
      case ApiErrorCode.authConfirmationTokenInvalid:
        return s.errorAuthConfirmationTokenInvalid;
      case ApiErrorCode.authConfirmationTokenExpired:
        return s.errorAuthConfirmationTokenExpired;
      case ApiErrorCode.authTokenExpired:
        return s.sessionExpired;
      case ApiErrorCode.authSubscriptionAuthRequired:
        return s.errorAuthSubscriptionRequired;

      case ApiErrorCode.validationFailed:
        return s.errorValidationFailed;
      case ApiErrorCode.validationFileTooLarge:
        return s.errorValidationFileTooLarge;
      case ApiErrorCode.validationFileTypeInvalid:
        return s.errorValidationFileTypeInvalid;
      case ApiErrorCode.validationGraphqlBodyTooLarge:
        return s.errorValidationRequestTooLarge;
      case ApiErrorCode.validationGraphqlComplexity:
        return s.errorValidationRequestTooComplex;

      case ApiErrorCode.orderNotFound:
        return s.errorOrderNotFound;
      case ApiErrorCode.orderNotClosed:
        return s.errorOrderNotClosed;
      case ApiErrorCode.partNotFound:
        return s.errorPartNotFound;
      case ApiErrorCode.workshopNotFound:
        return s.errorWorkshopNotFound;
      case ApiErrorCode.serviceNotFound:
        return s.errorServiceNotFound;
      case ApiErrorCode.conversationNotFound:
        return s.errorConversationNotFound;
      case ApiErrorCode.messageNotFound:
        return s.errorMessageNotFound;
      case ApiErrorCode.userNotFound:
        return s.errorAuthUserNotFound;
      case ApiErrorCode.resourceNotFound:
        return s.errorResourceNotFound;

      case ApiErrorCode.businessNotParticipant:
        return s.errorBusinessNotParticipant;
      case ApiErrorCode.businessNotAllowed:
        return s.errorBusinessNotAllowed;
      case ApiErrorCode.businessCannotReviewOwn:
        return s.errorBusinessCannotReviewOwn;
      case ApiErrorCode.businessAlreadyReviewed:
        return s.errorBusinessAlreadyReviewed;
      case ApiErrorCode.businessCannotBookOwn:
        return s.errorBusinessCannotBookOwn;
      case ApiErrorCode.businessCannotRespondOwnOrder:
        return s.errorBusinessCannotRespondOwnOrder;
      case ApiErrorCode.businessOrderWatchDenied:
        return s.errorBusinessOrderWatchDenied;
      case ApiErrorCode.businessMessageTooLong:
        return s.errorBusinessMessageTooLong;
      case ApiErrorCode.businessRateLimit:
        return s.errorBusinessRateLimit;

      case ApiErrorCode.wsUnauthenticated:
        return s.errorWsUnauthenticated;
      case ApiErrorCode.wsTooManyConnections:
        return s.errorWsTooManyConnections;
      case ApiErrorCode.wsHandshakeRateLimited:
        return s.errorWsHandshakeRateLimited;
      case ApiErrorCode.wsOriginNotAllowed:
        return s.errorWsOriginNotAllowed;
      case ApiErrorCode.deviceOffline:
        return s.errorDeviceOffline;

      case ApiErrorCode.internalError:
        return s.serverNotWorking;
      case ApiErrorCode.unknown:
        return s.errorGeneric;
    }
  }

  static ApiErrorPayload fromGraphqlError(GraphQLError error) {
    final ext = error.extensions;
    if (ext != null) {
      final fromExt = ApiErrorPayload.fromExtensions(
        Map<String, dynamic>.from(ext),
      );
      if (fromExt.code != ApiErrorCode.unknown) return fromExt;
    }
    // Backend formatError sets message === code.
    return ApiErrorPayload.fromGraphqlMessage(error.message);
  }

  static String messageFromGraphqlError(
    BuildContext context,
    GraphQLError error,
  ) {
    return localize(context, fromGraphqlError(error));
  }

  static String messageFromException(BuildContext context, Object? exception) {
    if (exception is OperationException) {
      final gql = exception.graphqlErrors;
      if (gql.isNotEmpty) {
        return messageFromGraphqlError(context, gql.first);
      }
      final link = exception.linkException;
      if (link is NetworkException || link is ServerException) {
        return S.of(context).noInternetConnection;
      }
    }
    return S.of(context).errorGeneric;
  }
}
