import 'package:equatable/equatable.dart';

import '../../domain/entities/chat_message.dart';
import '../../domain/entities/typing_event.dart';

sealed class ChatRoomEvent extends Equatable {
  const ChatRoomEvent();
  @override
  List<Object?> get props => const [];
}

final class ChatRoomOpened extends ChatRoomEvent {
  const ChatRoomOpened(this.conversationId);
  final String conversationId;
  @override
  List<Object?> get props => [conversationId];
}

final class ChatRoomLoadMore extends ChatRoomEvent {
  const ChatRoomLoadMore();
}

final class ChatRoomMessageReceived extends ChatRoomEvent {
  const ChatRoomMessageReceived(this.message);
  final ChatMessage message;
  @override
  List<Object?> get props => [message];
}

final class ChatRoomSendRequested extends ChatRoomEvent {
  const ChatRoomSendRequested({
    required this.text,
    this.imagePaths = const [],
    this.replyToMessageId,
    this.voicePath,
    this.voiceDurationMs,
  });
  final String text;

  /// Local file paths to attach. Each gets uploaded then sent as URL.
  final List<String> imagePaths;
  final String? replyToMessageId;
  final String? voicePath;
  final int? voiceDurationMs;

  @override
  List<Object?> get props => [
        text,
        imagePaths,
        replyToMessageId,
        voicePath,
        voiceDurationMs,
      ];
}

final class ChatRoomRetrySend extends ChatRoomEvent {
  const ChatRoomRetrySend(this.clientTempId);
  final String clientTempId;
  @override
  List<Object?> get props => [clientTempId];
}

final class ChatRoomTypingChanged extends ChatRoomEvent {
  const ChatRoomTypingChanged(this.isTyping);
  final bool isTyping;
  @override
  List<Object?> get props => [isTyping];
}

final class ChatRoomTypingReceived extends ChatRoomEvent {
  const ChatRoomTypingReceived(this.event);
  final TypingEvent event;
  @override
  List<Object?> get props => [event];
}

final class ChatRoomSubscriptionLost extends ChatRoomEvent {
  const ChatRoomSubscriptionLost();
}

final class ChatRoomResubscribe extends ChatRoomEvent {
  const ChatRoomResubscribe();
}

/// Silently merges page 1 from the server (used when inbox subscription
/// shows the thread changed but [messageReceived] did not arrive).
final class ChatRoomPrefetchLatest extends ChatRoomEvent {
  const ChatRoomPrefetchLatest();
}

/// Fired when we know the peer has read the room (e.g. their
/// `unreadCountChanged` arrived with `unread == 0`). We optimistically
/// mark all of *our* sent messages as read by them.
final class ChatRoomPeerReadAll extends ChatRoomEvent {
  const ChatRoomPeerReadAll(this.peerId);
  final String peerId;
  @override
  List<Object?> get props => [peerId];
}

final class ChatRoomDeleteMessageRequested extends ChatRoomEvent {
  const ChatRoomDeleteMessageRequested(this.messageId);
  final String messageId;
  @override
  List<Object?> get props => [messageId];
}

final class ChatRoomEditMessageRequested extends ChatRoomEvent {
  const ChatRoomEditMessageRequested({
    required this.messageId,
    required this.text,
  });
  final String messageId;
  final String text;
  @override
  List<Object?> get props => [messageId, text];
}
