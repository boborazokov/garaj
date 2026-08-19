import '../../domain/entities/chat_participant.dart';
import '../../domain/entities/conversation.dart';
import 'graphql_json.dart';


class ConversationDto {
  ConversationDto({
    required this.id,
    required this.participants,
    this.partId,
    this.partName,
    this.partImage,
    this.lastMessageText,
    this.lastMessageSenderId,
    this.lastMessageAt,
    this.unread = 0,
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

  factory ConversationDto.fromJson(Map<String, dynamic> json) {
    final participantsRaw = json['participants'] as List? ?? [];
    final participants = participantsRaw
        .map((e) => ChatParticipantDto.fromJson(
              Map<String, dynamic>.from(e as Map),
            ).toEntity())
        .toList();

    final part = json['part'];
    String? partId;
    String? partName;
    String? partImage;
    if (part is Map) {
      partId = graphqlIdToString(part['_id']);
      partName = part['name']?.toString();
      final imgs = part['images'];
      if (imgs is List && imgs.isNotEmpty) {
        partImage = imgs.first.toString();
      }
    }

    return ConversationDto(
      id: graphqlIdToString(json['_id']),
      participants: participants,
      partId: partId,
      partName: partName,
      partImage: partImage,
      lastMessageText: json['lastMessageText']?.toString(),
      lastMessageSenderId: json['lastMessageSender'] == null
          ? null
          : graphqlIdToString(json['lastMessageSender']),
      lastMessageAt: _parseDate(json['lastMessageAt']),
      unread: (json['unread'] as num?)?.toInt() ?? 0,
    );
  }

  Conversation toEntity({bool isPeerTyping = false}) => Conversation(
        id: id,
        participants: participants,
        partId: partId,
        partName: partName,
        partImage: partImage,
        lastMessageText: lastMessageText,
        lastMessageSenderId: lastMessageSenderId,
        lastMessageAt: lastMessageAt,
        unread: unread,
        isPeerTyping: isPeerTyping,
      );

  static DateTime? _parseDate(dynamic v) {
    if (v is String) {
      try {
        return DateTime.parse(v);
      } catch (_) {}
    }
    return null;
  }
}

class ChatParticipantDto {
  ChatParticipantDto({required this.id, required this.name, this.phone});

  final String id;
  final String name;
  final String? phone;

  factory ChatParticipantDto.fromJson(Map<String, dynamic> json) {
    return ChatParticipantDto(
      id: graphqlIdToString(json['_id']),
      name: (json['name'] ?? '').toString(),
      phone: json['phone']?.toString(),
    );
  }

  ChatParticipant toEntity() =>
      ChatParticipant(id: id, name: name, phone: phone);
}
