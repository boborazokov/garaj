import 'package:graphql_flutter/graphql_flutter.dart';
import '../dto/graphql_json.dart';

import '../../domain/failures/chat_failure.dart';
import '../api/chat_api.dart';
import '../dto/conversation_dto.dart';
import '../dto/message_dto.dart';
import '../dto/typing_event_dto.dart';

class PaginatedDto<T> {
  PaginatedDto({
    required this.items,
    required this.page,
    required this.totalPages,
    required this.hasNextPage,
    required this.totalDocs,
  });
  final List<T> items;
  final int page;
  final int totalPages;
  final bool hasNextPage;
  final int totalDocs;
}

/// Thin GraphQL transport for chat. Maps raw responses to DTOs and
/// normalizes exceptions into [ChatFailure].
class ChatRemoteDataSource {
  ChatRemoteDataSource(this._client);

  final GraphQLClient _client;

  Future<PaginatedDto<ConversationDto>> getConversations({
    int page = 1,
    int limit = 20,
  }) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(GET_CONVERSATIONS),
        variables: {
          'pagination': {'page': page, 'limit': limit},
        },
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );
    _throwOnError(result);

    final data = result.data!['getConversations'] as Map<String, dynamic>;
    final payload = (data['payload'] as List? ?? [])
        .map((e) => ConversationDto.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    return PaginatedDto(
      items: payload,
      page: (data['page'] as num?)?.toInt() ?? page,
      totalPages: (data['totalPages'] as num?)?.toInt() ?? 1,
      hasNextPage: data['hasNextPage'] == true,
      totalDocs: (data['totalDocs'] as num?)?.toInt() ?? payload.length,
    );
  }

  Future<PaginatedDto<MessageDto>> getMessages({
    required String conversationId,
    int page = 1,
    int limit = 30,
  }) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(GET_MESSAGES),
        variables: {
          'conversationId': conversationId,
          'pagination': {'page': page, 'limit': limit},
        },
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );
    _throwOnError(result);

    final data = result.data!['getMessages'] as Map<String, dynamic>;
    final payload = (data['payload'] as List? ?? [])
        .map(
          (e) => MessageDto.fromJson(
            Map<String, dynamic>.from(e as Map),
            conversationId: conversationId,
          ),
        )
        .toList();

    return PaginatedDto(
      items: payload,
      page: (data['page'] as num?)?.toInt() ?? page,
      totalPages: (data['totalPages'] as num?)?.toInt() ?? 1,
      hasNextPage: data['hasNextPage'] == true,
      totalDocs: (data['totalDocs'] as num?)?.toInt() ?? payload.length,
    );
  }

  Future<ConversationDto> createConversation({
    required String recipientId,
    String? partId,
  }) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(CREATE_CONVERSATION),
        variables: {
          'data': {
            'recipientId': recipientId,
            if (partId != null) 'partId': partId,
          },
        },
        fetchPolicy: FetchPolicy.noCache,
      ),
    );
    _throwOnError(result);
    return ConversationDto.fromJson(
      Map<String, dynamic>.from(result.data!['createConversation'] as Map),
    );
  }

  Future<MessageDto> sendMessage({
    required String conversationId,
    String? text,
    List<String>? images,
    String? replyToMessageId,
    String? voiceUrl,
    int? voiceDurationMs,
  }) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(SEND_MESSAGE),
        variables: {
          'data': {
            'conversationId': conversationId,
            if (text != null && text.isNotEmpty) 'text': text,
            if (images != null && images.isNotEmpty) 'images': images,
            if (replyToMessageId != null && replyToMessageId.isNotEmpty)
              'replyTo': replyToMessageId,
            if (voiceUrl != null && voiceUrl.isNotEmpty) 'voiceUrl': voiceUrl,
            if (voiceDurationMs != null && voiceDurationMs > 0)
              'voiceDurationMs': voiceDurationMs,
          },
        },
        fetchPolicy: FetchPolicy.noCache,
      ),
    );
    _throwOnError(result);
    return MessageDto.fromJson(
      Map<String, dynamic>.from(result.data!['sendMessage'] as Map),
      conversationId: conversationId,
    );
  }

  Future<bool> deleteConversationForMe(String conversationId) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(DELETE_CONVERSATION_FOR_ME),
        variables: {'conversationId': conversationId},
        fetchPolicy: FetchPolicy.noCache,
      ),
    );
    _throwOnError(result);
    return result.data!['deleteConversationForMe'] == true;
  }

  Future<bool> deleteMessageForMe(String messageId) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(DELETE_MESSAGE_FOR_ME),
        variables: {'messageId': messageId},
        fetchPolicy: FetchPolicy.noCache,
      ),
    );
    _throwOnError(result);
    return result.data!['deleteMessageForMe'] == true;
  }

  Future<MessageDto> updateMessage({
    required String messageId,
    required String conversationId,
    required String text,
  }) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(UPDATE_MESSAGE),
        variables: {
          'data': {
            'messageId': messageId,
            'text': text,
          },
        },
        fetchPolicy: FetchPolicy.noCache,
      ),
    );
    _throwOnError(result);
    final raw = Map<String, dynamic>.from(
      result.data!['updateMessage'] as Map,
    );
    return MessageDto.fromJson(raw, conversationId: conversationId);
  }

  Future<void> markAsRead(String conversationId) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(MARK_AS_READ),
        variables: {'conversationId': conversationId},
        fetchPolicy: FetchPolicy.noCache,
      ),
    );
    _throwOnError(result);
  }

  Future<void> setTyping({
    required String conversationId,
    required bool isTyping,
  }) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(SET_TYPING),
        variables: {
          'conversationId': conversationId,
          'isTyping': isTyping,
        },
        fetchPolicy: FetchPolicy.noCache,
      ),
    );
    _throwOnError(result);
  }

  Stream<MessageDto> subscribeMessages(String conversationId) {
    return _client
        .subscribe(
          SubscriptionOptions(
            document: gql(MESSAGE_RECEIVED_SUB),
            variables: {'conversationId': conversationId},
          ),
        )
        .where((r) => !r.hasException && r.data != null)
        .map((r) {
          if (r.hasException) throw _mapException(r.exception!);
          return MessageDto.fromJson(
            Map<String, dynamic>.from(r.data!['messageReceived'] as Map),
            conversationId: conversationId,
          );
        });
  }

  Stream<TypingEventDto> subscribeTyping(String conversationId) {
    return _client
        .subscribe(
          SubscriptionOptions(
            document: gql(TYPING_STATUS_SUB),
            variables: {'conversationId': conversationId},
          ),
        )
        .where((r) => !r.hasException && r.data != null)
        .map((r) => TypingEventDto.fromJson(
              Map<String, dynamic>.from(r.data!['typingStatus'] as Map),
            ));
  }

  Stream<ConversationDto> subscribeConversations() {
    return _client
        .subscribe(
          SubscriptionOptions(document: gql(CONVERSATION_UPDATED_SUB)),
        )
        .where((r) => !r.hasException && r.data != null)
        .map((r) => ConversationDto.fromJson(
              Map<String, dynamic>.from(r.data!['conversationUpdated'] as Map),
            ));
  }

  Stream<({String conversationId, int unread})> subscribeUnread() {
    return _client
        .subscribe(
          SubscriptionOptions(document: gql(UNREAD_COUNT_CHANGED_SUB)),
        )
        .where((r) => !r.hasException && r.data != null)
        .map((r) {
          final raw = r.data!['unreadCountChanged'] as Map;
          return (
            conversationId: graphqlIdToString(raw['conversationId']),
            unread: (raw['unread'] as num?)?.toInt() ?? 0,
          );
        });
  }

  void _throwOnError(QueryResult result) {
    if (result.hasException) {
      throw _mapException(result.exception!);
    }
  }

  ChatFailure _mapException(OperationException ex) {
    if (ex.linkException is NetworkException) {
      return const ChatNetworkFailure();
    }
    final link = ex.linkException;
    if (link is ServerException) {
      final parsed = link.parsedResponse?.errors;
      if (parsed != null && parsed.isNotEmpty) {
        return _mapGraphqlErrors(parsed);
      }
    }
    final errors = ex.graphqlErrors;
    if (errors.isNotEmpty) {
      return _mapGraphqlErrors(errors);
    }
    final detail = link?.toString();
    if (detail != null && detail.isNotEmpty) {
      return ChatServerFailure(detail);
    }
    return const ChatServerFailure();
  }

  ChatFailure _mapGraphqlErrors(List<GraphQLError> errors) {
    final first = errors.first;
    final code = first.extensions?['code']?.toString();
    final msg = first.message;
    if (code == 'UNAUTHENTICATED' ||
        msg.toLowerCase().contains('unauthorized')) {
      return const ChatAuthFailure();
    }
    return ChatValidationFailure(code ?? msg);
  }
}
