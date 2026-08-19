import 'package:equatable/equatable.dart';

/// Lifecycle of the push subsystem on the device.
enum NotificationsStatus { initial, bootstrapping, ready, denied, error }

class NotificationsState extends Equatable {
  const NotificationsState({
    this.status = NotificationsStatus.initial,
    this.permissionGranted = false,
    this.failureMessage,
  });

  final NotificationsStatus status;
  final bool permissionGranted;
  final String? failureMessage;

  NotificationsState copyWith({
    NotificationsStatus? status,
    bool? permissionGranted,
    String? failureMessage,
    bool clearFailure = false,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      permissionGranted: permissionGranted ?? this.permissionGranted,
      failureMessage: clearFailure
          ? null
          : (failureMessage ?? this.failureMessage),
    );
  }

  @override
  List<Object?> get props => [status, permissionGranted, failureMessage];
}
