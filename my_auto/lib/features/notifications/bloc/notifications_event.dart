import 'package:equatable/equatable.dart';

/// Inbound events for `NotificationsBloc`.
///
/// Naming follows the convention used elsewhere in the AutoRin Bloc
/// migration plan (verb-past or imperative).
sealed class NotificationsEvent extends Equatable {
  const NotificationsEvent();
  @override
  List<Object?> get props => const [];
}

/// Fired once at app start to spin up the push subsystem.
final class NotificationsBootstrapped extends NotificationsEvent {
  const NotificationsBootstrapped();
}

/// Fired after a successful sign-in. Triggers token registration.
final class NotificationsUserSignedIn extends NotificationsEvent {
  const NotificationsUserSignedIn();
}

/// Fired after sign-out. Triggers token removal.
final class NotificationsUserSignedOut extends NotificationsEvent {
  const NotificationsUserSignedOut();
}

/// Fired when permission status changes (e.g. user toggled it in
/// system settings). Cheap to emit; the bloc just stores it.
final class NotificationsPermissionChanged extends NotificationsEvent {
  const NotificationsPermissionChanged(this.granted);
  final bool granted;
  @override
  List<Object?> get props => [granted];
}
