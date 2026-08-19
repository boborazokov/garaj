import '../../domain/entities/typing_event.dart';
import 'graphql_json.dart';

class TypingEventDto {
  TypingEventDto({
    required this.conversationId,
    required this.userId,
    required this.isTyping,
  });

  final String conversationId;
  final String userId;
  final bool isTyping;

  factory TypingEventDto.fromJson(Map<String, dynamic> json) {
    return TypingEventDto(
      conversationId: graphqlIdToString(json['conversationId']),
      userId: graphqlIdToString(json['userId']),
      isTyping: json['isTyping'] == true,
    );
  }

  TypingEvent toEntity() => TypingEvent(
        conversationId: conversationId,
        userId: userId,
        isTyping: isTyping,
      );
}
