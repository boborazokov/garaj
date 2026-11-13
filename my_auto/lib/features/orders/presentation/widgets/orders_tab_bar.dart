import 'package:flutter/material.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/generated/l10n.dart';

import '../../domain/entities/orders_tab.dart';

/// Horizontal filter chips for the I-need feed (not segmented tabs).
class OrdersTabBar extends StatelessWidget {
  const OrdersTabBar({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final OrdersTab selected;
  final ValueChanged<OrdersTab> onChanged;

  String _label(S s, OrdersTab tab) {
    switch (tab) {
      case OrdersTab.all:
        return s.searchHubSectionOrders;
      case OrdersTab.myRequests:
        return s.myRequests;
      case OrdersTab.responded:
        return s.wantToBuyRespond;
      case OrdersTab.favorites:
        return s.favorites;
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return SizedBox(
      height: 40,
      child: ListView.separated(
        addAutomaticKeepAlives: false,
        scrollDirection: Axis.horizontal,
        itemCount: OrdersTab.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final tab = OrdersTab.values[index];
          final isSelected = tab == selected;
          final colors = context.appColors;
          return Material(
            color: isSelected ? colors.textPrimary : colors.surface,
            borderRadius: AppRadius.rXl,
            child: InkWell(
              onTap: () => onChanged(tab),
              borderRadius: AppRadius.rXl,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: AppRadius.rXl,
                  border: Border.all(
                    color: isSelected ? colors.textPrimary : colors.border,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  _label(s, tab),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color:
                        isSelected ? colors.background : colors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
