import 'package:equatable/equatable.dart';

sealed class ChatFailure extends Equatable {
  const ChatFailure(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

class ChatNetworkFailure extends ChatFailure {
  const ChatNetworkFailure([super.message = 'No internet connection']);
}

class ChatAuthFailure extends ChatFailure {
  const ChatAuthFailure([super.message = 'Session expired']);
}

class ChatServerFailure extends ChatFailure {
  const ChatServerFailure([super.message = 'Server error']);
}

class ChatValidationFailure extends ChatFailure {
  const ChatValidationFailure(super.message);
}
