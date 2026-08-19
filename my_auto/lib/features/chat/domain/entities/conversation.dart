import 'package:equatable/equatable.dart';

import 'chat_participant.dart';

class Conversation extends Equatable {
  const Conversation({
    required this.id,
    required this.participants,
    this.partId,
    this.partName,
    this.partImage,
    this.lastMessageText,
    this.lastMessageSenderId,
    this.lastMessageAt,
    this.unread = 0,
    this.isPeerTyping = false,
  });

  final String id;
  final List<ChatParticipant> participants;
  final String? partId;
  final String? partName;
  final String? partImage;
  final String? lastMessageText;
  final String? lastMessageSenderId;
  final DateTime? lastMessageAt;
  final int unread;
  final bool isPeerTyping;

  ChatParticipant? peerFor(String currentUserId) {
    for (final p in participants) {
      if (p.id != currentUserId) return p;
    }
    return participants.isNotEmpty ? participants.first : null;
  }

  Conversation copyWith({
    String? lastMessageText,
    String? lastMessageSenderId,
    DateTime? lastMessageAt,
    int? unread,
    bool? isPeerTyping,
    List<ChatParticipant>? participants,
  }) {
    return Conversation(
      id: id,
      participants: participants ?? this.participants,
      partId: partId,
      partName: partName,
      partImage: partImage,
      lastMessageText: lastMessageText ?? this.lastMessageText,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unread: unread ?? this.unread,
      isPeerTyping: isPeerTyping ?? this.isPeerTyping,
    );
  }

  @override
  List<Object?> get props => [
        id,
        participants,
        partId,
        partName,
        partImage,
        lastMessageText,
        lastMessageSenderId,
        lastMessageAt,
        unread,
        isPeerTyping,
      ];
}
