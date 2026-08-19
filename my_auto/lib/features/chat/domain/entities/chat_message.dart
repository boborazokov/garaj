import 'package:equatable/equatable.dart';

enum MessageDeliveryStatus { sending, sent, failed }

class ChatReplySnapshot extends Equatable {
  const ChatReplySnapshot({
    required this.messageId,
    this.senderId,
    this.senderName,
    this.text,
  });

  final String messageId;
  final String? senderId;
  final String? senderName;
  final String? text;

  @override
  List<Object?> get props => [messageId, senderId, senderName, text];
}

class ChatMessage extends Equatable {
  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.images,
    required this.createdAt,
    this.readBy = const [],
    this.deliveryStatus = MessageDeliveryStatus.sent,
    this.clientTempId,
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
  final MessageDeliveryStatus deliveryStatus;

  /// Present only for optimistic outbound messages before the server
  /// assigns a real `_id`.
  final String? clientTempId;

  final ChatReplySnapshot? replyTo;

  /// Public URL of the voice attachment (m4a / aac / ogg).
  final String? voiceUrl;
  final int? voiceDurationMs;

  bool get isFailed => deliveryStatus == MessageDeliveryStatus.failed;
  bool get isSending => deliveryStatus == MessageDeliveryStatus.sending;
  bool get hasImages => images.isNotEmpty;
  bool get hasVoice => (voiceUrl ?? '').isNotEmpty;
  bool get hasText => text.isNotEmpty;

  ChatMessage copyWith({
    String? id,
    String? text,
    MessageDeliveryStatus? deliveryStatus,
    List<String>? readBy,
    ChatReplySnapshot? replyTo,
    String? voiceUrl,
    int? voiceDurationMs,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      conversationId: conversationId,
      senderId: senderId,
      senderName: senderName,
      text: text ?? this.text,
      images: images,
      createdAt: createdAt,
      readBy: readBy ?? this.readBy,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      clientTempId: clientTempId,
      replyTo: replyTo ?? this.replyTo,
      voiceUrl: voiceUrl ?? this.voiceUrl,
      voiceDurationMs: voiceDurationMs ?? this.voiceDurationMs,
    );
  }

  @override
  List<Object?> get props => [
        id,
        conversationId,
        senderId,
        senderName,
        text,
        images,
        createdAt,
        readBy,
        deliveryStatus,
        clientTempId,
        replyTo,
        voiceUrl,
        voiceDurationMs,
      ];
}
