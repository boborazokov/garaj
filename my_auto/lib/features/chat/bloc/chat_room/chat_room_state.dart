import 'package:equatable/equatable.dart';

import '../../domain/entities/chat_message.dart';
import '../../domain/failures/chat_failure.dart';

enum ChatRoomStatus { initial, loading, success, loadingMore, empty, error }

class ChatRoomState extends Equatable {
  const ChatRoomState({
    this.status = ChatRoomStatus.initial,
    this.messages = const [],
    this.page = 1,
    this.hasMore = true,
    this.isPeerTyping = false,
    this.subscriptionAlive = true,
    this.failure,
    this.conversationId = '',
  });

  final ChatRoomStatus status;
  final List<ChatMessage> messages;
  final int page;
  final bool hasMore;
  final bool isPeerTyping;
  final bool subscriptionAlive;
  final ChatFailure? failure;
  final String conversationId;

  ChatRoomState copyWith({
    ChatRoomStatus? status,
    List<ChatMessage>? messages,
    int? page,
    bool? hasMore,
    bool? isPeerTyping,
    bool? subscriptionAlive,
    ChatFailure? failure,
    String? conversationId,
    bool clearFailure = false,
  }) {
    return ChatRoomState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isPeerTyping: isPeerTyping ?? this.isPeerTyping,
      subscriptionAlive: subscriptionAlive ?? this.subscriptionAlive,
      failure: clearFailure ? null : (failure ?? this.failure),
      conversationId: conversationId ?? this.conversationId,
    );
  }

  @override
  List<Object?> get props => [
        status,
        messages,
        page,
        hasMore,
        isPeerTyping,
        subscriptionAlive,
        failure,
        conversationId,
      ];
}
