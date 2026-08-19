import 'package:equatable/equatable.dart';

import '../../domain/entities/conversation.dart';

sealed class ChatsListEvent extends Equatable {
  const ChatsListEvent();
  @override
  List<Object?> get props => const [];
}

final class ChatsListStarted extends ChatsListEvent {
  const ChatsListStarted();
}

final class ChatsListRefreshed extends ChatsListEvent {
  const ChatsListRefreshed();
}

final class ChatsListLoadMore extends ChatsListEvent {
  const ChatsListLoadMore();
}

final class ChatsListConversationUpdated extends ChatsListEvent {
  const ChatsListConversationUpdated(this.conversation);
  final Conversation conversation;
  @override
  List<Object?> get props => [conversation];
}

final class ChatsListUnreadChanged extends ChatsListEvent {
  const ChatsListUnreadChanged({
    required this.conversationId,
    required this.unread,
  });
  final String conversationId;
  final int unread;
  @override
  List<Object?> get props => [conversationId, unread];
}

final class ChatsListTypingChanged extends ChatsListEvent {
  const ChatsListTypingChanged({
    required this.conversationId,
    required this.isTyping,
  });
  final String conversationId;
  final bool isTyping;
  @override
  List<Object?> get props => [conversationId, isTyping];
}

final class ChatsListSubscriptionLost extends ChatsListEvent {
  const ChatsListSubscriptionLost();
}

/// WS reconnected — full resync + resubscribe (debounced at service layer).
final class ChatsListWebSocketRecovered extends ChatsListEvent {
  const ChatsListWebSocketRecovered();
}

final class ChatsListDeleteRequested extends ChatsListEvent {
  const ChatsListDeleteRequested(this.conversationId);
  final String conversationId;
  @override
  List<Object?> get props => [conversationId];
}
