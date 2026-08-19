import 'dart:io';

import '../../domain/entities/chat_message.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/paginated_result.dart';
import '../../domain/entities/typing_event.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_local_datasource.dart';
import '../datasources/chat_remote_datasource.dart';
import '../datasources/chat_upload_datasource.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl({
    required ChatRemoteDataSource remote,
    required ChatLocalDataSource local,
    required ChatUploadDataSource uploads,
  })  : _remote = remote,
        _local = local,
        _uploads = uploads;

  final ChatRemoteDataSource _remote;
  final ChatLocalDataSource _local;
  final ChatUploadDataSource _uploads;

  @override
  Future<PaginatedResult<Conversation>> getConversations({
    int page = 1,
    int limit = 20,
  }) async {
    final dto = await _remote.getConversations(page: page, limit: limit);
    return PaginatedResult(
      items: dto.items.map((e) => e.toEntity()).toList(),
      page: dto.page,
      totalPages: dto.totalPages,
      hasNextPage: dto.hasNextPage,
      totalDocs: dto.totalDocs,
    );
  }

  @override
  Future<PaginatedResult<ChatMessage>> getMessages({
    required String conversationId,
    int page = 1,
    int limit = 30,
  }) async {
    try {
      final dto = await _remote.getMessages(
        conversationId: conversationId,
        page: page,
        limit: limit,
      );
      final items = dto.items.map((e) => e.toEntity()).toList();
      if (page == 1) {
        await _local.cacheMessages(conversationId, items);
      }
      return PaginatedResult(
        items: items,
        page: dto.page,
        totalPages: dto.totalPages,
        hasNextPage: dto.hasNextPage,
        totalDocs: dto.totalDocs,
      );
    } catch (_) {
      if (page == 1) {
        final cached = await _local.getCachedMessages(conversationId);
        if (cached.isNotEmpty) {
          return PaginatedResult(
            items: cached,
            page: 1,
            totalPages: 1,
            hasNextPage: false,
            totalDocs: cached.length,
          );
        }
      }
      rethrow;
    }
  }

  @override
  Future<Conversation> createConversation({
    required String recipientId,
    String? partId,
  }) async {
    final existing = await _findConversationWithRecipient(recipientId);
    if (existing != null) return existing;

    final dto = await _remote.createConversation(
      recipientId: recipientId,
      partId: partId,
    );
    return dto.toEntity();
  }

  /// One inbox thread per seller — reuse if the user already messaged them.
  Future<Conversation?> _findConversationWithRecipient(String recipientId) async {
    var page = 1;
    while (true) {
      final result = await getConversations(page: page, limit: 50);
      for (final conversation in result.items) {
        if (conversation.participants.any((p) => p.id == recipientId)) {
          return conversation;
        }
      }
      if (!result.hasNextPage) break;
      page++;
    }
    return null;
  }

  @override
  Future<bool> deleteConversationForMe(String conversationId) =>
      _remote.deleteConversationForMe(conversationId);

  @override
  Future<bool> deleteMessageForMe(String messageId) =>
      _remote.deleteMessageForMe(messageId);

  @override
  Future<ChatMessage> updateMessage({
    required String messageId,
    required String conversationId,
    required String text,
  }) async {
    final dto = await _remote.updateMessage(
      messageId: messageId,
      conversationId: conversationId,
      text: text,
    );
    return dto.toEntity();
  }

  @override
  Future<ChatMessage> sendMessage({
    required String conversationId,
    String? text,
    List<String>? images,
    String? replyToMessageId,
    String? voiceUrl,
    int? voiceDurationMs,
  }) async {
    final dto = await _remote.sendMessage(
      conversationId: conversationId,
      text: text,
      images: images,
      replyToMessageId: replyToMessageId,
      voiceUrl: voiceUrl,
      voiceDurationMs: voiceDurationMs,
    );
    return dto.toEntity();
  }

  @override
  Future<String> uploadChatImage(String filePath) =>
      _uploads.uploadImage(File(filePath));

  @override
  Future<String> uploadChatVoice(String filePath) =>
      _uploads.uploadVoice(File(filePath));

  @override
  Future<void> markAsRead(String conversationId) =>
      _remote.markAsRead(conversationId);

  @override
  Future<void> setTyping({
    required String conversationId,
    required bool isTyping,
  }) =>
      _remote.setTyping(conversationId: conversationId, isTyping: isTyping);

  @override
  Stream<ChatMessage> watchMessages(String conversationId) {
    return _remote.subscribeMessages(conversationId).map((d) => d.toEntity());
  }

  @override
  Stream<TypingEvent> watchTyping(String conversationId) {
    return _remote.subscribeTyping(conversationId).map((d) => d.toEntity());
  }

  @override
  Stream<Conversation> watchConversations() {
    return _remote.subscribeConversations().map((d) => d.toEntity());
  }

  @override
  Stream<({String conversationId, int unread})> watchUnreadCounts() =>
      _remote.subscribeUnread();

  @override
  Future<List<ChatMessage>> getCachedMessages(String conversationId) =>
      _local.getCachedMessages(conversationId);

  @override
  Future<void> cacheMessages(
    String conversationId,
    List<ChatMessage> messages,
  ) =>
      _local.cacheMessages(conversationId, messages);

  @override
  Future<void> enqueueOutboxMessage(ChatMessage pending) =>
      _local.enqueueOutbox(pending.conversationId, pending);

  @override
  Future<List<ChatMessage>> drainOutbox(String conversationId) =>
      _local.drainOutbox(conversationId);

  @override
  Future<void> clearSessionCaches() => _local.clearSession();
}
