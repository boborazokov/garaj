/// GraphQL operation strings used by the notifications feature.
///
/// Kept in a dedicated file (matching the existing `features/*/api`
/// convention used elsewhere in the project) so the queries can be
/// reviewed independently of the Dart logic.
const String REGISTER_DEVICE_TOKEN_MUTATION = r"""
mutation RegisterDeviceToken($data: RegisterDeviceTokenInput!) {
  registerDeviceToken(data: $data) {
    _id
    token
    platform
    isActive
  }
}
""";

const String REMOVE_DEVICE_TOKEN_MUTATION = r"""
mutation RemoveDeviceToken($token: String!) {
  removeDeviceToken(token: $token)
}
""";

const String GET_MY_NOTIFICATIONS = r'''
query GetMyNotifications($pagination: PaginationInput) {
  getMyNotifications(pagination: $pagination) {
    totalDocs
    hasNextPage
    payload {
      _id
      type
      title
      body
      deepLink
      isRead
      createdAt
    }
  }
}
''';

const String MY_UNREAD_NOTIFICATIONS_COUNT = r'''
query MyUnreadNotificationsCount {
  myUnreadNotificationsCount
}
''';

const String MARK_NOTIFICATION_READ = r'''
mutation MarkNotificationRead($notificationId: ObjectId!) {
  markNotificationRead(notificationId: $notificationId)
}
''';

const String MARK_ALL_NOTIFICATIONS_READ = r'''
mutation MarkAllNotificationsRead {
  markAllNotificationsRead
}
''';
