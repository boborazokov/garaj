import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_auto/core/auth/pending_action.dart';
import 'package:my_auto/core/provider/auth/auth.dart';
import 'package:my_auto/core/provider/home/setFavorite/index.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/features/chat/chat_di.dart';
import 'package:my_auto/features/chat/domain/failures/chat_failure.dart';
import 'package:my_auto/main.dart';
import 'package:provider/provider.dart';

/// Central store for post-login action replay.
class PendingActionManager {
  PendingActionManager._();
  static final PendingActionManager instance = PendingActionManager._();

  PendingAction? _pending;

  PendingAction? get current => _pending;

  void set(PendingAction action) {
    _pending = action;
  }

  void setRoute(String path, [Object? extra]) {
    _pending = PendingRoute(path: path, extra: extra);
  }

  void clear() => _pending = null;

  /// Returns `true` if a pending action was consumed and replayed.
  Future<bool> replay(BuildContext context) async {
    final action = _pending;
    if (action == null) return false;
    _pending = null;

    if (!context.mounted) return false;

    try {
      switch (action) {
        case PendingRoute(:final path, :final extra):
          if (extra != null) {
            context.push(path, extra: extra);
          } else {
            context.push(path);
          }
          return true;

        case PendingWriteSeller(
            :final recipientId,
            :final partId,
            :final sellerName,
          ):
          final conversation = await chatRepository.createConversation(
            recipientId: recipientId,
            partId: partId.isEmpty ? null : partId,
          );
          if (!context.mounted) return true;
          context.push(
            '${RoutesName.chatDetail}/${conversation.id}',
            extra: sellerName,
          );
          return true;

        case PendingToggleFavorite(:final partId, :final serviceId):
          if (partId.isEmpty) return true;
          if (!context.mounted) return true;
          context
              .read<SetFavoriteProvider>()
              .toggleFavoriteDebounced(serviceId, partId);
          return true;

        case PendingAddProduct():
          if (!context.mounted) return true;
          context.push(RoutesName.addProduct);
          return true;

        case PendingOpenMyStore():
          if (!context.mounted) return true;
          final id = context.read<AuthProvider>().auth?.user.id;
          if (id != null && id.isNotEmpty) {
            context.push(RoutesName.sellerProfile, extra: id);
          }
          return true;

        case PendingCreateOrder(:final initialTitle):
          if (!context.mounted) return true;
          context.push(RoutesName.createOrder, extra: initialTitle);
          return true;

        case PendingOpenChat(:final conversationId, :final peerTitle):
          if (!context.mounted) return true;
          context.push(
            '${RoutesName.chatDetail}/$conversationId',
            extra: peerTitle,
          );
          return true;
      }
    } on ChatFailure catch (e) {
      _showError(e.message);
      return true;
    } catch (e) {
      _showError(e.toString());
      return true;
    }
  }

  void _showError(String message) {
    final ctx = navigatorKey.currentContext;
    if (ctx == null || !ctx.mounted) return;
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(message)));
  }
}
