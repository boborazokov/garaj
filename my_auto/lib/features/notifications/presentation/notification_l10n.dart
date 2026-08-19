import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:my_auto/features/notifications/data/models/app_notification.dart';
import 'package:my_auto/features/notifications/notifications_constants.dart';
import 'package:my_auto/generated/l10n.dart';

class LocalizedNotificationCopy {
  const LocalizedNotificationCopy({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;
}

/// Resolves [S] from the widget tree, falling back to the last loaded locale.
S resolveNotificationStrings([BuildContext? context]) {
  if (context != null) {
    final fromTree = S.maybeOf(context);
    if (fromTree != null) return fromTree;
  }
  try {
    return S.current;
  } catch (_) {
    return S();
  }
}

/// Localizes FCM [RemoteMessage] title/body for tray display.
LocalizedNotificationCopy localizeRemoteMessage(
  S s,
  RemoteMessage message,
) {
  final data = message.data;
  final type = data[PushDataKeys.type]?.toString() ?? '';
  final title =
      message.notification?.title ?? data['title']?.toString() ?? '';
  final body = message.notification?.body ?? data['body']?.toString() ?? '';

  return localizePushPayload(
    s,
    type: type,
    title: title,
    body: body,
  );
}

/// Localizes push/inbox payload fields.
LocalizedNotificationCopy localizePushPayload(
  S s, {
  required String type,
  required String title,
  required String body,
}) {
  return localizeNotification(
    s,
    AppNotification(
      id: '',
      type: type,
      title: title,
      body: body,
      isRead: true,
      createdAt: DateTime.now(),
    ),
  );
}

/// Maps server-stored notification text to in-app locale strings.
///
/// Chat and other user-generated alerts keep the backend title/body
/// (sender name, message text). System alerts are translated client-side.
LocalizedNotificationCopy localizeNotification(S s, AppNotification n) {
  final type = n.type.trim().toLowerCase();
  final title = n.title.trim();
  final body = n.body.trim();

  if (_isChatUserMessage(type, title, body)) {
    return LocalizedNotificationCopy(title: title, body: body);
  }

  if (type == PushEventTypes.chat) {
    return LocalizedNotificationCopy(
      title: _nonEmpty(title, s.notificationNewMessageTitle),
      body: _nonEmpty(body, s.notificationNewMessageBody),
    );
  }

  if (_isAccountVerified(type, title, body)) {
    return LocalizedNotificationCopy(
      title: s.notificationAccountVerifiedTitle,
      body: s.notificationAccountVerifiedBody,
    );
  }

  switch (type) {
    case PushEventTypes.newFollower:
      return LocalizedNotificationCopy(
        title: s.notificationNewFollowerTitle,
        body: _nonEmpty(body, s.notificationNewFollowerBody),
      );
    case PushEventTypes.orderReply:
      return LocalizedNotificationCopy(
        title: _nonEmpty(title, s.notificationOrderReplyTitle),
        body: _nonEmpty(body, s.notificationOrderReplyBody),
      );
    case PushEventTypes.promotedExpired:
      return LocalizedNotificationCopy(
        title: s.notificationPromotedExpiredTitle,
        body: _nonEmpty(body, s.notificationPromotedExpiredBody),
      );
    case PushEventTypes.favoriteMatched:
      return LocalizedNotificationCopy(
        title: _nonEmpty(title, s.notificationFavoriteMatchedTitle),
        body: _nonEmpty(body, s.notificationFavoriteMatchedBody),
      );
    case PushEventTypes.sellerResponse:
      return LocalizedNotificationCopy(
        title: _nonEmpty(title, s.notificationSellerResponseTitle),
        body: body,
      );
    case PushEventTypes.accountVerified:
      return LocalizedNotificationCopy(
        title: s.notificationAccountVerifiedTitle,
        body: s.notificationAccountVerifiedBody,
      );
    case PushEventTypes.workshopBooking:
    case 'workshopbooking':
    case 'workshopreply':
    case 'workshop_booking':
      return LocalizedNotificationCopy(
        title: _nonEmpty(title, s.notificationWorkshopBookingTitle),
        body: _nonEmpty(body, s.notificationWorkshopBookingBody),
      );
    default:
      final legacy = _matchLegacyEnglish(s, title, body);
      if (legacy != null) return legacy;

      if (_isGenericAppSender(title)) {
        return LocalizedNotificationCopy(
          title: s.notificationGenericAlertTitle,
          body: _nonEmpty(body, s.notificationGenericAlertBody),
        );
      }

      return LocalizedNotificationCopy(title: title, body: body);
  }
}

bool _isChatUserMessage(String type, String title, String body) {
  if (type != PushEventTypes.chat) return false;
  if (body.isEmpty) return false;
  return !_isGenericAppSender(title) && !_isSystemChatTitle(title);
}

bool _isSystemChatTitle(String title) {
  final t = title.toLowerCase();
  return t == 'new message' ||
      t == 'new chat' ||
      t.contains('sent you a message');
}

bool _isGenericAppSender(String title) {
  final t = title.toLowerCase();
  return t == 'garage' ||
      t == 'autorin' ||
      t == 'my auto' ||
      t == 'myauto' ||
      t.isEmpty;
}

bool _isAccountVerified(String type, String title, String body) {
  if (type.contains('verified') ||
      type == PushEventTypes.accountVerified ||
      type == 'sellerverified' ||
      type == 'userverified') {
    return true;
  }

  final t = title.toLowerCase();
  final b = body.toLowerCase();
  return t.contains('verified') ||
      b.contains('verified') ||
      t.contains('account is now verified') ||
      b.contains('account is now verified');
}

LocalizedNotificationCopy? _matchLegacyEnglish(
  S s,
  String title,
  String body,
) {
  final t = title.toLowerCase();
  final b = body.toLowerCase();

  if (t.contains('verified') || b.contains('verified')) {
    return LocalizedNotificationCopy(
      title: s.notificationAccountVerifiedTitle,
      body: s.notificationAccountVerifiedBody,
    );
  }

  if (t.contains('new follower') ||
      b.contains('started following') ||
      b.contains('followed your')) {
    return LocalizedNotificationCopy(
      title: s.notificationNewFollowerTitle,
      body: _nonEmpty(body, s.notificationNewFollowerBody),
    );
  }

  if (t.contains('order') ||
      b.contains('order') ||
      t.contains('buy request') ||
      b.contains('buy request')) {
    return LocalizedNotificationCopy(
      title: _nonEmpty(title, s.notificationOrderReplyTitle),
      body: _nonEmpty(body, s.notificationOrderReplyBody),
    );
  }

  if (t.contains('promotion') ||
      t.contains('promoted') ||
      b.contains('no longer promoted') ||
      b.contains('promotion ended')) {
    return LocalizedNotificationCopy(
      title: s.notificationPromotedExpiredTitle,
      body: _nonEmpty(body, s.notificationPromotedExpiredBody),
    );
  }

  if (t.contains('price match') ||
      t.contains('favorite') ||
      b.contains('saved listing')) {
    return LocalizedNotificationCopy(
      title: s.notificationFavoriteMatchedTitle,
      body: _nonEmpty(body, s.notificationFavoriteMatchedBody),
    );
  }

  if (t.contains('seller') && t.contains('repl')) {
    return LocalizedNotificationCopy(
      title: s.notificationSellerResponseTitle,
      body: body,
    );
  }

  if (t.contains('workshop') ||
      t.contains('booking') ||
      b.contains('workshop') ||
      b.contains('service reply')) {
    return LocalizedNotificationCopy(
      title: _nonEmpty(title, s.notificationWorkshopBookingTitle),
      body: _nonEmpty(body, s.notificationWorkshopBookingBody),
    );
  }

  if (t == 'new message' ||
      t.contains('new message') ||
      b == 'new message' ||
      (t == 'garage' && b.contains('message'))) {
    return LocalizedNotificationCopy(
      title: s.notificationNewMessageTitle,
      body: _nonEmpty(body, s.notificationNewMessageBody),
    );
  }

  if (t.contains('error') ||
      t.contains('failed') ||
      b.contains('error') ||
      b.contains('failed')) {
    return LocalizedNotificationCopy(
      title: _nonEmpty(title, s.error),
      body: _nonEmpty(body, s.errorOccurred),
    );
  }

  return null;
}

String _nonEmpty(String value, String fallback) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? fallback : trimmed;
}
