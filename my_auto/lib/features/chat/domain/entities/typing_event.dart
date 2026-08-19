import 'package:equatable/equatable.dart';

class TypingEvent extends Equatable {
  const TypingEvent({
    required this.conversationId,
    required this.userId,
    required this.isTyping,
  });

  final String conversationId;
  final String userId;
  final bool isTyping;

  @override
  List<Object?> get props => [conversationId, userId, isTyping];
}
