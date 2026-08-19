import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

import '../../domain/entities/conversation.dart';
import '../../domain/failures/chat_failure.dart';
import '../../domain/repositories/chat_repository.dart';
import 'chats_list_event.dart';
import 'chats_list_state.dart';

class ChatsListBloc extends Bloc<ChatsListEvent, ChatsListState> {
  ChatsListBloc({
    required ChatRepository repository,
    required String currentUserId,
  })  : _repository = repository,
        _currentUserId = currentUserId,
        super(const ChatsListState()) {
    on<ChatsListStarted>(_onStarted);
    on<ChatsListRefreshed>(_onRefreshed, transformer: droppable());
    on<ChatsListLoadMore>(_onLoadMore, transformer: droppable());
    on<ChatsListConversationUpdated>(_onConversationUpdated);
    on<ChatsListUnreadChanged>(_onUnreadChanged);
    on<ChatsListTypingChanged>(_onTypingChanged);
    on<ChatsListDeleteRequested>(_onDeleteRequested);
    on<ChatsListSubscriptionLost>((_, emit) {
      emit(state.copyWith(subscriptionAlive: false));
    });
    on<ChatsListWebSocketRecovered>(_onWebSocketRecovered);
  }

  final ChatRepository _repository;
  final String _currentUserId;

  StreamSubscription<Conversation>? _convSub;
  StreamSubscription<({String conversationId, int unread})>? _unreadSub;

  Future<void> _onStarted(
    ChatsListStarted event,
    Emitter<ChatsListState> emit,
  ) async {
    await _load(emit, reset: true);
    _subscribe();
  }

  Future<void> _onRefreshed(
    ChatsListRefreshed event,
    Emitter<ChatsListState> emit,
  ) =>
      _load(emit, reset: true);

  Future<void> _onLoadMore(
    ChatsListLoadMore event,
    Emitter<ChatsListState> emit,
  ) async {
    if (!state.hasMore || state.status == ChatsListStatus.loadingMore) return;
    emit(state.copyWith(status: ChatsListStatus.loadingMore));
    await _load(emit, reset: false);
  }

  Future<void> _load(Emitter<ChatsListState> emit, {required bool reset}) async {
    if (reset) {
      emit(state.copyWith(
        status: ChatsListStatus.loading,
        conversations: [],
        page: 1,
        hasMore: true,
        clearFailure: true,
      ));
    }

    try {
      final page = reset ? 1 : state.page;
      final result = await _repository.getConversations(page: page, limit: 20);

      final merged = reset
          ? result.items
          : [
              ...state.conversations,
              ...result.items.where(
                (n) => !state.conversations.any((c) => c.id == n.id),
              ),
            ];

      _sortInPlace(merged);

      emit(state.copyWith(
        status: merged.isEmpty ? ChatsListStatus.empty : ChatsListStatus.success,
        conversations: merged,
        page: page + 1,
        hasMore: result.hasNextPage,
        subscriptionAlive: true,
        clearFailure: true,
      ));
    } on ChatFailure catch (f) {
      emit(state.copyWith(status: ChatsListStatus.error, failure: f));
    } catch (e) {
      emit(state.copyWith(
        status: ChatsListStatus.error,
        failure: ChatServerFailure(e.toString()),
      ));
    }
  }

  void _onConversationUpdated(
    ChatsListConversationUpdated event,
    Emitter<ChatsListState> emit,
  ) {
    final updated = event.conversation;
    final list = [
      updated,
      ...state.conversations.where((c) => c.id != updated.id),
    ];
    _sortInPlace(list);
    emit(state.copyWith(
      conversations: list,
      status: list.isEmpty ? ChatsListStatus.empty : ChatsListStatus.success,
      subscriptionAlive: true,
    ));
  }

  void _onUnreadChanged(
    ChatsListUnreadChanged event,
    Emitter<ChatsListState> emit,
  ) {
    final list = state.conversations.map((c) {
      if (c.id != event.conversationId) return c;
      return c.copyWith(unread: event.unread);
    }).toList();
    emit(state.copyWith(conversations: list));
  }

  void _onTypingChanged(
    ChatsListTypingChanged event,
    Emitter<ChatsListState> emit,
  ) {
    final list = state.conversations.map((c) {
      if (c.id != event.conversationId) return c;
      return c.copyWith(isPeerTyping: event.isTyping);
    }).toList();
    emit(state.copyWith(conversations: list));
  }

  Future<void> _onDeleteRequested(
    ChatsListDeleteRequested event,
    Emitter<ChatsListState> emit,
  ) async {
    try {
      await _repository.deleteConversationForMe(event.conversationId);
      final list =
          state.conversations.where((c) => c.id != event.conversationId).toList();
      emit(state.copyWith(
        conversations: list,
        status: list.isEmpty ? ChatsListStatus.empty : ChatsListStatus.success,
        clearFailure: true,
      ));
    } on ChatFailure catch (f) {
      emit(state.copyWith(failure: f));
    } catch (e) {
      emit(state.copyWith(failure: ChatServerFailure(e.toString())));
    }
  }

  Future<void> _onWebSocketRecovered(
    ChatsListWebSocketRecovered event,
    Emitter<ChatsListState> emit,
  ) async {
    _subscribe();
    await _load(emit, reset: true);
  }

  void _subscribe() {
    _convSub?.cancel();
    _unreadSub?.cancel();

    _convSub = _repository.watchConversations().listen(
      (c) => add(ChatsListConversationUpdated(c)),
      onError: (_, __) => add(const ChatsListSubscriptionLost()),
    );

    _unreadSub = _repository.watchUnreadCounts().listen(
      (e) => add(ChatsListUnreadChanged(
        conversationId: e.conversationId,
        unread: e.unread,
      )),
      onError: (_, __) => add(const ChatsListSubscriptionLost()),
    );
  }

  void _sortInPlace(List<Conversation> list) {
    list.sort((a, b) {
      final at = a.lastMessageAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bt = b.lastMessageAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bt.compareTo(at);
    });
  }

  @override
  Future<void> close() async {
    await _convSub?.cancel();
    await _unreadSub?.cancel();
    return super.close();
  }
}
