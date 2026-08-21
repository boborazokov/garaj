import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/image_cache/index.dart';

import '../../domain/entities/order.dart';
import '../../domain/entities/order_response.dart';
import '../../domain/entities/order_response_listing.dart';

class OrderResponseCard extends StatelessWidget {
  const OrderResponseCard({
    super.key,
    required this.response,
    required this.request,
    required this.onChat,
    this.onCall,
  });

  final OrderResponse response;
  final Order request;
  final VoidCallback onChat;
  final VoidCallback? onCall;

  String _formatDate(DateTime dt) =>
      DateFormat('dd MMM yyyy, HH:mm').format(dt.toLocal());

  String _priceLabel(S s) {
    final price = response.offeredPrice;
    if (price == null || price <= 0) return '';
    final cur = request.currency?.isNotEmpty == true
        ? request.currency!
        : 'UZS';
    return s.orderDetailOfferPrice('$cur $price');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    final seller = response.seller;
    final listing = response.listing;
    final priceLabel = _priceLabel(s);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.rXl,
        border: Border.all(color: colors.border.withValues(alpha: 0.45)),
        boxShadow: AppShadows.card(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: colors.primary.withValues(alpha: 0.12),
                  child: Text(
                    seller.name.isNotEmpty ? seller.name[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: colors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        seller.name,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      Text(
                        _formatDate(response.createdAt),
                        style: TextStyle(fontSize: 12, color: colors.textMuted),
                      ),
                    ],
                  ),
                ),
                if (response.isAccepted)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: colors.success.withValues(alpha: 0.14),
                      borderRadius: AppRadius.rM,
                    ),
                    child: Text(
                      s.orderDetailAcceptedOffer,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: colors.success,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (priceLabel.isNotEmpty) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                priceLabel,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: colors.primary,
                ),
              ),
            ),
          ],
          if (listing != null) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _ListingOfferTile(
                listing: listing,
                subtitle: s.orderDetailAlternativeListing,
                viewLabel: s.orderDetailViewListing,
              ),
            ),
          ],
          if (response.text.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                response.text.trim(),
                style: const TextStyle(height: 1.45, fontSize: 15),
              ),
            ),
          ],
          if (response.deliveryDays != null) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(LucideIcons.truck, size: 14, color: colors.textMuted),
                  const SizedBox(width: 6),
                  Text(
                    s.orderDetailDeliveryDays(response.deliveryDays!),
                    style: TextStyle(fontSize: 12, color: colors.textMuted),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: onChat,
                    icon: const Icon(LucideIcons.messageSquare, size: 18),
                    label: Text(s.orderDetailChatSeller),
                  ),
                ),
                if (onCall != null) ...[
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: onCall,
                    icon: const Icon(LucideIcons.phone, size: 18),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ListingOfferTile extends StatelessWidget {
  const _ListingOfferTile({
    required this.listing,
    required this.subtitle,
    required this.viewLabel,
  });

  final OrderResponseListing listing;
  final String subtitle;
  final String viewLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final id = listing.id;
    final name = listing.name;
    final imageUrl = listing.imageUrl;
    final price = listing.price;
    final currency = listing.currency;

    return Material(
      color: colors.surfaceMuted,
      borderRadius: AppRadius.rL,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('${RoutesName.productDetailScreen}/$id'),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: imageUrl != null && imageUrl.isNotEmpty
                      ? ImageCacheNetwork(
                          url: imageUrl,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                        )
                      : ColoredBox(
                          color: colors.border.withValues(alpha: 0.3),
                          child: Icon(
                            LucideIcons.package,
                            color: colors.textMuted,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: colors.info,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    if (price != null && price > 0) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${currency ?? 'UZS'} $price',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: colors.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Text(
                viewLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: colors.primary,
                ),
              ),
              Icon(LucideIcons.chevronRight, size: 18, color: colors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
