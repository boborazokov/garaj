import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_auto/core/auth/auth_guard.dart';
import 'package:my_auto/core/auth/pending_action.dart';
import 'package:my_auto/core/provider/auth/auth.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/features/chat/chat_di.dart';
import 'package:my_auto/features/chat/domain/failures/chat_failure.dart';
import 'package:my_auto/features/orders/domain/entities/order.dart';
import 'package:provider/provider.dart';

/// Opens a chat with the order author (buyer who posted the request).
Future<void> openOrderAuthorChat(BuildContext context, Order order) async {
  final author = order.author;
  if (author == null || author.id.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(S.of(context).errorAuthorUnavailable)),
    );
    return;
  }

  final authed = await AuthGuard.requireAuth(
    context,
    pending: PendingWriteSeller(
      recipientId: author.id,
      partId: '',
      sellerName: author.name,
    ),
    message: S.of(context).signInToMessageBuyer,
  );
  if (!authed || !context.mounted) return;

  final userId = context.read<AuthProvider>().auth?.user.id;
  if (userId == author.id) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(S.of(context).errorCannotMessageSelf)),
    );
    return;
  }

  try {
    final conversation = await chatRepository.createConversation(
      recipientId: author.id,
    );
    if (!context.mounted) return;
    context.push(
      '${RoutesName.chatDetail}/${conversation.id}',
      extra: author.name,
    );
  } on ChatFailure catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.message)),
    );
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString())),
    );
  }
}
