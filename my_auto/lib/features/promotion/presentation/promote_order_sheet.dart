import 'package:flutter/material.dart';
import 'package:my_auto/features/orders/domain/entities/order.dart';
import 'package:my_auto/features/promotion/data/promotion_repository.dart';
import 'package:my_auto/features/promotion/presentation/promote_plan_sheet.dart';
import 'package:my_auto/generated/l10n.dart';

Future<bool?> showPromoteOrderSheet(
  BuildContext context, {
  required Order order,
}) {
  return showPromotePlanSheet(
    context,
    listingTitle: order.title,
    isPromotionActive: order.isPromoted,
    sheetTitle: S.of(context).promoteListingTitle,
    onPromote: (plan) => promotionRepository.purchasePromotion(
      targetType: PromotionTargetType.order,
      targetId: order.id,
      plan: plan,
    ),
  );
}
