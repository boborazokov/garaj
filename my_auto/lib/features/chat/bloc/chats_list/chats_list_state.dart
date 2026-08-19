import 'package:equatable/equatable.dart';

import '../../domain/entities/conversation.dart';
import '../../domain/failures/chat_failure.dart';

enum ChatsListStatus { initial, loading, success, loadingMore, empty, error }

class ChatsListState extends Equatable {
  const ChatsListState({
    this.status = ChatsListStatus.initial,
    this.conversations = const [],
    this.page = 1,
    this.hasMore = true,
    this.subscriptionAlive = true,
    this.failure,
  });

  final ChatsListStatus status;
  final List<Conversation> conversations;
  final int page;
  final bool hasMore;
  final bool subscriptionAlive;
  final ChatFailure? failure;

  int get totalUnread =>
      conversations.fold<int>(0, (sum, c) => sum + c.unread);

  ChatsListState copyWith({
    ChatsListStatus? status,
    List<Conversation>? conversations,
    int? page,
    bool? hasMore,
    bool? subscriptionAlive,
    ChatFailure? failure,
    bool clearFailure = false,
  }) {
    return ChatsListState(
      status: status ?? this.status,
      conversations: conversations ?? this.conversations,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      subscriptionAlive: subscriptionAlive ?? this.subscriptionAlive,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props =>
      [status, conversations, page, hasMore, subscriptionAlive, failure];
}
