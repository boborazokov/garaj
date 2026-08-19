import 'package:equatable/equatable.dart';

class ChatParticipant extends Equatable {
  const ChatParticipant({
    required this.id,
    required this.name,
    this.phone,
  });

  final String id;
  final String name;
  final String? phone;

  @override
  List<Object?> get props => [id, name, phone];
}
