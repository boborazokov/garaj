import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:my_auto/core/network/websocket_recovery_service.dart';
import 'package:my_auto/features/chat/bloc/chat_room/chat_room_bloc.dart';
import 'package:my_auto/features/chat/bloc/chat_room/chat_room_event.dart';
import 'package:my_auto/features/chat/bloc/chats_list/chats_list_bloc.dart';
import 'package:my_auto/features/chat/bloc/chats_list/chats_list_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// After WS reconnect: resubscribe + delta sync without duplicate events.
class ChatRealtimeRecovery extends StatefulWidget {
  const ChatRealtimeRecovery({
    super.key,
    required this.child,
    this.enableChatsList = true,
    this.enableChatRoom = true,
  });

  final Widget child;
  final bool enableChatsList;
  final bool enableChatRoom;

  @override
  State<ChatRealtimeRecovery> createState() => _ChatRealtimeRecoveryState();
}

class _ChatRealtimeRecoveryState extends State<ChatRealtimeRecovery> {
  StreamSubscription<WebSocketRecoveryEvent>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = WebSocketRecoveryService.instance.events.listen(_onRecovered);
  }

  void _onRecovered(WebSocketRecoveryEvent event) {
    if (!mounted) return;
    if (widget.enableChatsList) {
      try {
        context.read<ChatsListBloc>().add(const ChatsListWebSocketRecovered());
      } catch (_) {}
    }
    if (widget.enableChatRoom) {
      try {
        context.read<ChatRoomBloc>().add(const ChatRoomResubscribe());
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
