import '../entities/chat_message.dart';
import '../entities/conversation.dart';
import '../entities/paginated_result.dart';
import '../entities/typing_event.dart';

/// Contract for chat data access. UI and Blocs depend on this interface
/// only — never on GraphQL or sqflite directly.
abstract class ChatRepository {
  Future<PaginatedResult<Conversation>> getConversations({
    int page = 1,
    int limit = 20,
  });

  Future<PaginatedResult<ChatMessage>> getMessages({
    required String conversationId,
    int page = 1,
    int limit = 30,
  });

  Future<Conversation> createConversation({
    required String recipientId,
    String? partId,
  });

  Future<bool> deleteConversationForMe(String conversationId);

  Future<bool> deleteMessageForMe(String messageId);

  Future<ChatMessage> updateMessage({
    required String messageId,
    required String conversationId,
    required String text,
  });

  Future<ChatMessage> sendMessage({
    required String conversationId,
    String? text,
    List<String>? images,
    String? replyToMessageId,
    String? voiceUrl,
    int? voiceDurationMs,
  });

  /// Uploads an image to a chat-specific bucket; returns the public URL.
  Future<String> uploadChatImage(String filePath);

  /// Uploads a voice file to a chat-specific bucket; returns the public URL.
  Future<String> uploadChatVoice(String filePath);

  Future<void> markAsRead(String conversationId);

  Future<void> setTyping({
    required String conversationId,
    required bool isTyping,
  });

  /// Room-scoped realtime stream. Caller must cancel the subscription.
  Stream<ChatMessage> watchMessages(String conversationId);

  Stream<TypingEvent> watchTyping(String conversationId);

  /// Inbox-level updates (new message, unread bump).
  Stream<Conversation> watchConversations();

  Stream<({String conversationId, int unread})> watchUnreadCounts();

  /// Offline foundation — cache hooks (no-op until sqflite ships).
  Future<List<ChatMessage>> getCachedMessages(String conversationId);
  Future<void> cacheMessages(String conversationId, List<ChatMessage> messages);
  Future<void> enqueueOutboxMessage(ChatMessage pending);
  Future<List<ChatMessage>> drainOutbox(String conversationId);

  /// Clears local chat buffers after sign-out.
  Future<void> clearSessionCaches();
}
