import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/push_service.dart';
import 'notifications_event.dart';
import 'notifications_state.dart';

/// Thin coordinator between the auth lifecycle and the `PushService`.
///
/// The bloc itself owns no business state beyond a `status` flag; the
/// real work happens inside `PushService` (which talks to FCM and the
/// backend). Keeping the bloc minimal means there's only one place
/// where the UI / auth flow needs to dispatch — and zero state to
/// recover after a hot reload.
class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  NotificationsBloc({required this.pushService})
      : super(const NotificationsState()) {
    // `droppable` because bootstrap is idempotent — if the user spams
    // a re-bootstrap event we shouldn't queue them up.
    on<NotificationsBootstrapped>(_onBootstrapped, transformer: droppable());
    on<NotificationsUserSignedIn>(_onSignedIn, transformer: sequential());
    on<NotificationsUserSignedOut>(_onSignedOut, transformer: sequential());
    on<NotificationsPermissionChanged>(_onPermissionChanged);
  }

  final PushService pushService;

  Future<void> _onBootstrapped(
    NotificationsBootstrapped event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(state.copyWith(
      status: NotificationsStatus.bootstrapping,
      clearFailure: true,
    ));
    try {
      await pushService.bootstrap();
      emit(state.copyWith(status: NotificationsStatus.ready));
    } catch (e) {
      emit(state.copyWith(
        status: NotificationsStatus.error,
        failureMessage: e.toString(),
      ));
    }
  }

  Future<void> _onSignedIn(
    NotificationsUserSignedIn event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      await pushService.onSignedIn();
    } catch (e) {
      emit(state.copyWith(
        status: NotificationsStatus.error,
        failureMessage: e.toString(),
      ));
    }
  }

  Future<void> _onSignedOut(
    NotificationsUserSignedOut event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      await pushService.onSignedOut();
    } catch (e) {
      emit(state.copyWith(
        status: NotificationsStatus.error,
        failureMessage: e.toString(),
      ));
    }
  }

  void _onPermissionChanged(
    NotificationsPermissionChanged event,
    Emitter<NotificationsState> emit,
  ) {
    emit(state.copyWith(
      permissionGranted: event.granted,
      status: event.granted
          ? NotificationsStatus.ready
          : NotificationsStatus.denied,
    ));
  }

  @override
  Future<void> close() async {
    await pushService.dispose();
    return super.close();
  }
}
