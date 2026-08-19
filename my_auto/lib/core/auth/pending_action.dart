/// Actions replayed after the user signs in from a guest wall.
sealed class PendingAction {
  const PendingAction();
}

final class PendingRoute extends PendingAction {
  const PendingRoute({required this.path, this.extra});
  final String path;
  final Object? extra;
}

final class PendingWriteSeller extends PendingAction {
  const PendingWriteSeller({
    required this.recipientId,
    required this.partId,
    required this.sellerName,
  });
  final String recipientId;
  final String partId;
  final String sellerName;
}

final class PendingToggleFavorite extends PendingAction {
  const PendingToggleFavorite({required this.partId, this.serviceId});
  final String partId;
  final String? serviceId;
}

final class PendingAddProduct extends PendingAction {
  const PendingAddProduct();
}

final class PendingCreateOrder extends PendingAction {
  const PendingCreateOrder({this.initialTitle});
  final String? initialTitle;
}

final class PendingOpenChat extends PendingAction {
  const PendingOpenChat({required this.conversationId, this.peerTitle});
  final String conversationId;
  final String? peerTitle;
}
