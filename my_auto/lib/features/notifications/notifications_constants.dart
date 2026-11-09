/// Channel + payload constants for push notifications.
///
/// All hard-coded strings live in one place so they stay in sync with
/// the server (`autorin-backend/src/services/push/push.service.ts`).
class PushChannels {
  PushChannels._();

  /// High-importance channel used for chat and any user-actionable
  /// real-time event. Must match the value in:
  ///  - AndroidManifest meta-data `default_notification_channel_id`
  ///  - backend `AndroidConfig.notification.channelId`
  static const String highId = 'autorin_high';
  // Display names are resolved at runtime via [S.pushChannelName] /
  // [S.pushChannelDescription] in PushService.
  static const String highName = 'Garage notifications';
  static const String highDescription =
      'Chat messages, order replies, and other real-time alerts.';
}

/// Keys for the FCM `data` payload. Kept here so the parser and the
/// server stay in sync.
class PushDataKeys {
  PushDataKeys._();
  static const String type = 'type';
  static const String deepLink = 'deepLink';
  static const String conversationId = 'conversationId';
  static const String senderId = 'senderId';
  static const String orderId = 'orderId';
  static const String partId = 'partId';
  static const String sellerId = 'sellerId';
  static const String amount = 'amount';
  static const String amountLabel = 'amountLabel';
  static const String currency = 'currency';
  static const String reason = 'reason';
  static const String reasonCode = 'reasonCode';
  static const String plan = 'plan';
}

/// Event type identifiers — match `PushEventType` on the backend.
class PushEventTypes {
  PushEventTypes._();
  static const String chat = 'chat';
  static const String orderReply = 'orderReply';
  static const String orderMatched = 'orderMatched';
  static const String favoriteMatched = 'favoriteMatched';
  static const String promotedExpired = 'promotedExpired';
  static const String sellerResponse = 'sellerResponse';
  static const String accountVerified = 'accountVerified';
  static const String workshopBooking = 'workshopBooking';
  static const String walletTopUp = 'walletTopUp';
  static const String walletSpend = 'walletSpend';
}
