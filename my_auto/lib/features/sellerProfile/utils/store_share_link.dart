String buildStoreShareLink({
  required String sellerId,
  String? username,
}) {
  final handle = username?.trim();
  if (handle != null && handle.isNotEmpty) {
    return 'https://garage.uz/store/$handle';
  }
  return 'https://garage.uz/seller/$sellerId';
}
