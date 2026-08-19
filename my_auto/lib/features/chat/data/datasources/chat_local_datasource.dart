import '../../domain/entities/chat_message.dart';

/// Offline-first abstraction. Stage 1: in-memory cache + outbox only.
/// Replace internals with sqflite without changing [ChatRepository].
abstract class ChatLocalDataSource {
  Future<List<ChatMessage>> getCachedMessages(String conversationId);
  Future<void> cacheMessages(String conversationId, List<ChatMessage> messages);
  Future<void> enqueueOutbox(String conversationId, ChatMessage message);
  Future<List<ChatMessage>> drainOutbox(String conversationId);

  /// Drop in-memory lists (logout / account switch).
  Future<void> clearSession();
}

class InMemoryChatLocalDataSource implements ChatLocalDataSource {
  final Map<String, List<ChatMessage>> _cache = {};
  final Map<String, List<ChatMessage>> _outbox = {};

  @override
  Future<List<ChatMessage>> getCachedMessages(String conversationId) async {
    return List<ChatMessage>.from(_cache[conversationId] ?? const []);
  }

  @override
  Future<void> cacheMessages(
    String conversationId,
    List<ChatMessage> messages,
  ) async {
    _cache[conversationId] = List<ChatMessage>.from(messages);
  }

  @override
  Future<void> enqueueOutbox(String conversationId, ChatMessage message) async {
    _outbox.putIfAbsent(conversationId, () => []).add(message);
  }

  @override
  Future<List<ChatMessage>> drainOutbox(String conversationId) async {
    final pending = _outbox.remove(conversationId) ?? [];
    return List<ChatMessage>.from(pending);
  }

  @override
  Future<void> clearSession() async {
    _cache.clear();
    _outbox.clear();
  }
}
