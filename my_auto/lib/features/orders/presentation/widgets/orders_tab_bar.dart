import 'package:flutter/material.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';

import '../../domain/entities/orders_tab.dart';

class OrdersTabBar extends StatelessWidget {
  const OrdersTabBar({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final OrdersTab selected;
  final ValueChanged<OrdersTab> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: colors.surfaceMuted,
          borderRadius: AppRadius.rXl,
        ),
        child: Row(
          children: OrdersTab.values.map((tab) {
            final isSelected = tab == selected;
            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(tab),
                child: AnimatedContainer(
                  duration: AppMotion.fast,
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? colors.surface : Colors.transparent,
                    borderRadius: AppRadius.rL,
                    boxShadow: isSelected ? AppShadows.card(context) : null,
                  ),
                  child: Text(
                    _label(tab),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? colors.textPrimary : colors.textMuted,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  String _label(OrdersTab tab) {
    switch (tab) {
      case OrdersTab.all:
        return 'All';
      case OrdersTab.myRequests:
        return 'My';
      case OrdersTab.responded:
        return 'Responded';
      case OrdersTab.favorites:
        return 'Saved';
    }
  }
}
