import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

import '../../data/dto/graphql_json.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/failures/chat_failure.dart';
import '../../domain/repositories/chat_repository.dart';
import 'chat_room_event.dart';
import 'chat_room_state.dart';

class ChatRoomBloc extends Bloc<ChatRoomEvent, ChatRoomState> {
  ChatRoomBloc({
    required ChatRepository repository,
    required String currentUserId,
    required String currentUserName,
  })  : _repository = repository,
        _currentUserId = currentUserId,
        _currentUserName = currentUserName,
        super(const ChatRoomState()) {
    on<ChatRoomOpened>(_onOpened);
    on<ChatRoomLoadMore>(_onLoadMore, transformer: droppable());
    on<ChatRoomMessageReceived>(_onMessageReceived);
    on<ChatRoomSendRequested>(_onSend, transformer: sequential());
    on<ChatRoomRetrySend>(_onRetry, transformer: sequential());
    on<ChatRoomTypingChanged>(_onTypingChanged);
    on<ChatRoomTypingReceived>(_onTypingReceived);
    on<ChatRoomSubscriptionLost>((_, emit) {
      emit(state.copyWith(subscriptionAlive: false));
    });
    on<ChatRoomResubscribe>(_onResubscribe);
    on<ChatRoomPrefetchLatest>(
      _onPrefetchLatest,
      transformer: sequential(),
    );
    on<ChatRoomPeerReadAll>(_onPeerReadAll);
    on<ChatRoomDeleteMessageRequested>(_onDeleteMessage);
    on<ChatRoomEditMessageRequested>(_onEditMessage, transformer: sequential());
  }

  final ChatRepository _repository;
  final String _currentUserId;
  final String _currentUserName;

  StreamSubscription<ChatMessage>? _msgSub;
  StreamSubscription? _typingSub;
  StreamSubscription<Conversation>? _inboxSub;
  StreamSubscription<({String conversationId, int unread})>? _unreadSub;
  Timer? _typingOffTimer;
  Timer? _inboxPrefetchDebounce;
  Timer? _syncPollTimer;

  Future<void> _onOpened(
    ChatRoomOpened event,
    Emitter<ChatRoomState> emit,
  ) async {
    emit(state.copyWith(
      conversationId: event.conversationId,
      status: ChatRoomStatus.loading,
      messages: [],
      page: 1,
      hasMore: true,
      clearFailure: true,
    ));

    try {
      final result = await _repository.getMessages(
        conversationId: event.conversationId,
        page: 1,
        limit: 30,
      );

      final sorted = List<ChatMessage>.from(result.items)
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      emit(state.copyWith(
        status: sorted.isEmpty ? ChatRoomStatus.empty : ChatRoomStatus.success,
        messages: sorted,
        page: 2,
        hasMore: result.hasNextPage,
        subscriptionAlive: true,
      ));

      _subscribe(event.conversationId);
      unawaited(_repository.markAsRead(event.conversationId));
    } on ChatFailure catch (f) {
      emit(state.copyWith(status: ChatRoomStatus.error, failure: f));
    } catch (e) {
      emit(state.copyWith(
        status: ChatRoomStatus.error,
        failure: ChatServerFailure(e.toString()),
      ));
    }
  }

  Future<void> _onLoadMore(
    ChatRoomLoadMore event,
    Emitter<ChatRoomState> emit,
  ) async {
    if (!state.hasMore || state.status == ChatRoomStatus.loadingMore) return;
    emit(state.copyWith(status: ChatRoomStatus.loadingMore));

    try {
      final result = await _repository.getMessages(
        conversationId: state.conversationId,
        page: state.page,
        limit: 30,
      );

      final older = result.items
          .where((m) => !state.messages.any((x) => x.id == m.id))
          .toList();

      final merged = [...state.messages, ...older]
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      emit(state.copyWith(
        status: ChatRoomStatus.success,
        messages: merged,
        page: state.page + 1,
        hasMore: result.hasNextPage,
      ));
    } on ChatFailure catch (f) {
      emit(state.copyWith(failure: f));
    }
  }

  void _onMessageReceived(
    ChatRoomMessageReceived event,
    Emitter<ChatRoomState> emit,
  ) {
    final m = event.message;
    final existingIndex = state.messages.indexWhere((x) => x.id == m.id);
    if (existingIndex >= 0) {
      final next = List<ChatMessage>.from(state.messages);
      next[existingIndex] = m;
      next.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      emit(state.copyWith(messages: next, status: ChatRoomStatus.success));
      return;
    }

    final next = [m, ...state.messages]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    emit(state.copyWith(
      messages: next,
      status: ChatRoomStatus.success,
      subscriptionAlive: true,
    ));

    if (m.senderId != _currentUserId) {
      unawaited(_repository.markAsRead(state.conversationId));
    }
  }

  Future<void> _onSend(
    ChatRoomSendRequested event,
    Emitter<ChatRoomState> emit,
  ) async {
    final text = event.text.trim();
    final hasImages = event.imagePaths.isNotEmpty;
    final hasVoice = (event.voicePath ?? '').isNotEmpty;
    if (text.isEmpty && !hasImages && !hasVoice) return;

    final tempId = 'temp-${DateTime.now().microsecondsSinceEpoch}';

    // Optimistic snapshot for reply (only the local id; preview text is
    // looked up from the messages list below).
    ChatReplySnapshot? replySnapshot;
    if (event.replyToMessageId != null) {
      final orig = state.messages
          .where((m) => m.id == event.replyToMessageId)
          .toList();
      if (orig.isNotEmpty) {
        final m = orig.first;
        replySnapshot = ChatReplySnapshot(
          messageId: m.id,
          senderId: m.senderId,
          senderName: m.senderName,
          text: m.text.isNotEmpty
              ? m.text
              : (m.hasImages ? '[photo]' : m.hasVoice ? '[voice]' : ''),
        );
      }
    }

    final optimistic = ChatMessage(
      id: tempId,
      conversationId: state.conversationId,
      senderId: _currentUserId,
      senderName: _currentUserName,
      text: text,
      images: event.imagePaths, // shown locally; replaced with URLs on success
      createdAt: DateTime.now(),
      deliveryStatus: MessageDeliveryStatus.sending,
      clientTempId: tempId,
      replyTo: replySnapshot,
      voiceUrl: event.voicePath,
      voiceDurationMs: event.voiceDurationMs,
    );

    final next = [optimistic, ...state.messages];
    emit(state.copyWith(messages: next, status: ChatRoomStatus.success));

    try {
      // Upload media first.
      final uploadedImages = <String>[];
      for (final path in event.imagePaths) {
        final url = await _repository.uploadChatImage(path);
        uploadedImages.add(url);
      }
      String? voiceUrl;
      if (event.voicePath != null && event.voicePath!.isNotEmpty) {
        voiceUrl = await _repository.uploadChatVoice(event.voicePath!);
      }

      final saved = await _repository.sendMessage(
        conversationId: state.conversationId,
        text: text,
        images: uploadedImages,
        replyToMessageId: event.replyToMessageId,
        voiceUrl: voiceUrl,
        voiceDurationMs: event.voiceDurationMs,
      );
      final replaced = state.messages
          .map((m) => m.clientTempId == tempId ? saved : m)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      emit(state.copyWith(messages: replaced));
    } on ChatFailure catch (f) {
      final failed = state.messages
          .map(
            (m) => m.clientTempId == tempId
                ? m.copyWith(deliveryStatus: MessageDeliveryStatus.failed)
                : m,
          )
          .toList();
      emit(state.copyWith(messages: failed, failure: f));
    } catch (_) {
      final failed = state.messages
          .map(
            (m) => m.clientTempId == tempId
                ? m.copyWith(deliveryStatus: MessageDeliveryStatus.failed)
                : m,
          )
          .toList();
      emit(state.copyWith(
        messages: failed,
        failure: const ChatNetworkFailure(),
      ));
    }
  }

  Future<void> _onRetry(
    ChatRoomRetrySend event,
    Emitter<ChatRoomState> emit,
  ) async {
    final failed = state.messages
        .where((m) => m.clientTempId == event.clientTempId)
        .toList();
    if (failed.isEmpty) return;
    final m = failed.first;
    add(ChatRoomSendRequested(
      text: m.text,
      imagePaths: m.images,
      replyToMessageId: m.replyTo?.messageId,
      voicePath: m.voiceUrl,
      voiceDurationMs: m.voiceDurationMs,
    ));
    final without = state.messages
        .where((x) => x.clientTempId != event.clientTempId)
        .toList();
    emit(state.copyWith(messages: without));
  }

  Future<void> _onTypingChanged(
    ChatRoomTypingChanged event,
    Emitter<ChatRoomState> emit,
  ) async {
    _typingOffTimer?.cancel();
    try {
      await _repository.setTyping(
        conversationId: state.conversationId,
        isTyping: event.isTyping,
      );
    } catch (_) {}

    if (event.isTyping) {
      _typingOffTimer = Timer(const Duration(seconds: 3), () {
        add(const ChatRoomTypingChanged(false));
      });
    }
  }

  void _onTypingReceived(
    ChatRoomTypingReceived event,
    Emitter<ChatRoomState> emit,
  ) {
    if (event.event.userId == _currentUserId) return;
    emit(state.copyWith(isPeerTyping: event.event.isTyping));
  }

  void _onPeerReadAll(
    ChatRoomPeerReadAll event,
    Emitter<ChatRoomState> emit,
  ) {
    final updated = state.messages.map((m) {
      if (m.senderId != _currentUserId) return m;
      if (m.readBy.contains(event.peerId)) return m;
      return m.copyWith(readBy: [...m.readBy, event.peerId]);
    }).toList();
    emit(state.copyWith(messages: updated));
  }

  Future<void> _onDeleteMessage(
    ChatRoomDeleteMessageRequested event,
    Emitter<ChatRoomState> emit,
  ) async {
    final target = state.messages.where((m) => m.id == event.messageId).toList();
    if (target.isEmpty) return;
    final message = target.first;

    if (message.clientTempId != null || message.isSending) {
      final next =
          state.messages.where((m) => m.id != event.messageId).toList();
      emit(state.copyWith(
        messages: next,
        status: next.isEmpty ? ChatRoomStatus.empty : ChatRoomStatus.success,
      ));
      return;
    }

    try {
      await _repository.deleteMessageForMe(event.messageId);
      final next =
          state.messages.where((m) => m.id != event.messageId).toList();
      emit(state.copyWith(
        messages: next,
        status: next.isEmpty ? ChatRoomStatus.empty : ChatRoomStatus.success,
        clearFailure: true,
      ));
    } on ChatFailure catch (f) {
      emit(state.copyWith(failure: f));
    } catch (e) {
      emit(state.copyWith(failure: ChatServerFailure(e.toString())));
    }
  }

  Future<void> _onEditMessage(
    ChatRoomEditMessageRequested event,
    Emitter<ChatRoomState> emit,
  ) async {
    final text = event.text.trim();
    if (text.isEmpty) return;

    final target = state.messages.where((m) => m.id == event.messageId).toList();
    if (target.isEmpty) return;
    final message = target.first;
    if (message.hasImages) return;

    try {
      final updated = await _repository.updateMessage(
        messageId: event.messageId,
        conversationId: state.conversationId,
        text: text,
      );
      final next = state.messages
          .map((m) => m.id == event.messageId ? updated : m)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      emit(state.copyWith(messages: next, clearFailure: true));
    } on ChatFailure catch (f) {
      emit(state.copyWith(failure: f));
    } catch (e) {
      emit(state.copyWith(failure: ChatServerFailure(e.toString())));
    }
  }

  Future<void> _onResubscribe(
    ChatRoomResubscribe event,
    Emitter<ChatRoomState> emit,
  ) async {
    _subscribe(state.conversationId);
    emit(state.copyWith(subscriptionAlive: true));
    try {
      final result = await _repository.getMessages(
        conversationId: state.conversationId,
        page: 1,
        limit: 30,
      );
      final sorted = List<ChatMessage>.from(result.items)
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      emit(state.copyWith(messages: sorted, page: 2, hasMore: result.hasNextPage));
    } catch (_) {}
  }

  Future<void> _onPrefetchLatest(
    ChatRoomPrefetchLatest event,
    Emitter<ChatRoomState> emit,
  ) async {
    final convId = state.conversationId;
    if (convId.isEmpty) return;
    if (state.status == ChatRoomStatus.loading) return;

    try {
      final result = await _repository.getMessages(
        conversationId: convId,
        page: 1,
        limit: 30,
      );

      final byId = {for (final m in state.messages) m.id: m};
      for (final m in result.items) {
        byId[m.id] = m;
      }
      final merged = byId.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      emit(state.copyWith(
        messages: merged,
        status: merged.isEmpty ? ChatRoomStatus.empty : ChatRoomStatus.success,
        subscriptionAlive: true,
      ));
    } catch (_) {}
  }

  void _scheduleDebouncedPrefetch() {
    _inboxPrefetchDebounce?.cancel();
    _inboxPrefetchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (!isClosed) add(const ChatRoomPrefetchLatest());
    });
  }

  void _subscribe(String conversationId) {
    final cid = conversationId.trim();

    _msgSub?.cancel();
    _typingSub?.cancel();
    _inboxSub?.cancel();
    _unreadSub?.cancel();
    _inboxPrefetchDebounce?.cancel();
    _syncPollTimer?.cancel();

    _msgSub = _repository.watchMessages(cid).listen(
          (m) => add(ChatRoomMessageReceived(m)),
          onError: (_, __) => add(const ChatRoomSubscriptionLost()),
          cancelOnError: false,
        );

    _typingSub = _repository.watchTyping(cid).listen(
          (e) => add(ChatRoomTypingReceived(e)),
          onError: (_, __) => add(const ChatRoomSubscriptionLost()),
          cancelOnError: false,
        );

    // Fallback: if per-room `messageReceived` is flaky, `conversationUpdated`
    // usually still fires when the last message changes — pull page 1 briefly.
    _inboxSub = _repository.watchConversations().listen(
          (c) {
            if (!graphqlIdsEqual(c.id, cid)) return;
            _scheduleDebouncedPrefetch();
          },
          onError: (_, __) => add(const ChatRoomSubscriptionLost()),
          cancelOnError: false,
        );

    _unreadSub = _repository.watchUnreadCounts().listen(
          (e) {
            if (!graphqlIdsEqual(e.conversationId, cid)) return;
            _scheduleDebouncedPrefetch();
          },
          onError: (_, __) => add(const ChatRoomSubscriptionLost()),
          cancelOnError: false,
        );

    _syncPollTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (isClosed) {
        return;
      }
      if (state.status == ChatRoomStatus.loading ||
          state.status == ChatRoomStatus.loadingMore ||
          state.status == ChatRoomStatus.error) {
        return;
      }
      add(const ChatRoomPrefetchLatest());
    });
  }

  @override
  Future<void> close() async {
    _typingOffTimer?.cancel();
    _inboxPrefetchDebounce?.cancel();
    _syncPollTimer?.cancel();
    if (state.conversationId.isNotEmpty) {
      unawaited(
        _repository.setTyping(
          conversationId: state.conversationId,
          isTyping: false,
        ),
      );
    }
    await _msgSub?.cancel();
    await _typingSub?.cancel();
    await _inboxSub?.cancel();
    await _unreadSub?.cancel();
    return super.close();
  }
}
