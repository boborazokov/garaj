import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:my_auto/core/services/graphql/index.dart';
import 'package:my_auto/features/notifications/data/api/notifications_api.dart';
import 'package:my_auto/features/notifications/data/models/app_notification.dart';

class NotificationsInboxRepository {
  Future<PaginatedAppNotifications> fetchInbox({
    int page = 1,
    int limit = 30,
  }) async {
    final result = await GraphQLConfig.client().query(
      QueryOptions(
        document: gql(GET_MY_NOTIFICATIONS),
        variables: {
          'pagination': {'page': page, 'limit': limit},
        },
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );
    if (result.hasException) throw result.exception!;
    final data = result.data?['getMyNotifications'];
    if (data == null) {
      return const PaginatedAppNotifications(
        items: [],
        hasNextPage: false,
        totalDocs: 0,
      );
    }
    return PaginatedAppNotifications.fromJson(
      Map<String, dynamic>.from(data as Map),
    );
  }

  Future<int> unreadCount() async {
    final result = await GraphQLConfig.client().query(
      QueryOptions(
        document: gql(MY_UNREAD_NOTIFICATIONS_COUNT),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );
    if (result.hasException) throw result.exception!;
    return (result.data?['myUnreadNotificationsCount'] as num?)?.toInt() ?? 0;
  }

  Future<bool> markRead(String notificationId) async {
    final result = await GraphQLConfig.client().mutate(
      MutationOptions(
        document: gql(MARK_NOTIFICATION_READ),
        variables: {'notificationId': notificationId},
      ),
    );
    if (result.hasException) throw result.exception!;
    return result.data?['markNotificationRead'] == true;
  }

  Future<int> markAllRead() async {
    final result = await GraphQLConfig.client().mutate(
      MutationOptions(document: gql(MARK_ALL_NOTIFICATIONS_READ)),
    );
    if (result.hasException) throw result.exception!;
    return (result.data?['markAllNotificationsRead'] as num?)?.toInt() ?? 0;
  }
}

final notificationsInboxRepository = NotificationsInboxRepository();
