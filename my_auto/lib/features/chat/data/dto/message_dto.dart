import '../../domain/entities/chat_message.dart';
import 'graphql_json.dart';

class MessageDto {
  MessageDto({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.images,
    required this.createdAt,
    required this.readBy,
    this.replyTo,
    this.voiceUrl,
    this.voiceDurationMs,
  });

  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String text;
  final List<String> images;
  final DateTime createdAt;
  final List<String> readBy;
  final ChatReplySnapshot? replyTo;
  final String? voiceUrl;
  final int? voiceDurationMs;

  factory MessageDto.fromJson(
    Map<String, dynamic> json, {
    required String conversationId,
  }) {
    final sender = json['sender'];
    String senderId = '';
    String senderName = '';
    if (sender is Map) {
      senderId = graphqlIdToString(sender['_id']);
      senderName = sender['name']?.toString() ?? '';
    }

    final readByRaw = json['readBy'] as List? ?? [];
    final readBy = readByRaw
        .map(_idFromDynamic)
        .where((id) => id.isNotEmpty)
        .toList();

    final imagesRaw = json['images'] as List? ?? [];
    final images = imagesRaw.map((e) => e.toString()).toList();

    ChatReplySnapshot? reply;
    final replyId = graphqlIdToString(json['replyTo']);
    if (replyId.isNotEmpty) {
      reply = ChatReplySnapshot(
        messageId: replyId,
        senderId: graphqlIdToString(json['replyToSenderId']),
        senderName: json['replyToSenderName']?.toString(),
        text: json['replyToText']?.toString(),
      );
    }

    return MessageDto(
      id: graphqlIdToString(json['_id']),
      conversationId: conversationId,
      senderId: senderId,
      senderName: senderName,
      text: (json['text'] ?? '').toString(),
      images: images,
      createdAt: _parseDate(json['createdAt']) ?? DateTime.now(),
      readBy: readBy,
      replyTo: reply,
      voiceUrl: (json['voiceUrl']?.toString() ?? '').isEmpty
          ? null
          : json['voiceUrl'].toString(),
      voiceDurationMs: (json['voiceDurationMs'] as num?)?.toInt(),
    );
  }

  ChatMessage toEntity({MessageDeliveryStatus status = MessageDeliveryStatus.sent}) {
    return ChatMessage(
      id: id,
      conversationId: conversationId,
      senderId: senderId,
      senderName: senderName,
      text: text,
      images: images,
      createdAt: createdAt,
      readBy: readBy,
      deliveryStatus: status,
      replyTo: replyTo,
      voiceUrl: voiceUrl,
      voiceDurationMs: voiceDurationMs,
    );
  }

  static DateTime? _parseDate(dynamic v) {
    if (v is String) {
      try {
        return DateTime.parse(v);
      } catch (_) {}
    }
    return null;
  }

  static String _idFromDynamic(dynamic v) => graphqlIdToString(v);
}
