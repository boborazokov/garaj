import 'package:flutter/material.dart';
import 'package:my_auto/core/model/product/index.dart';
import 'package:my_auto/features/promotion/data/promotion_repository.dart';
import 'package:my_auto/features/promotion/presentation/promote_plan_sheet.dart';
import 'package:my_auto/features/wallet/data/wallet_repository.dart';
import 'package:my_auto/generated/l10n.dart';

Future<bool?> showPromoteProductSheet(
  BuildContext context, {
  required Part product,
}) {
  return showPromotePlanSheet(
    context,
    listingTitle: product.name,
    isPromotionActive: product.isPromotionActive,
    activePlan: product.promotionPlan,
    promotedUntil: product.promotedUntil,
    sheetTitle: S.of(context).promoteProductTitle,
    onPromote: (plan) => promotionRepository.purchasePromotion(
      targetType: PromotionTargetType.part,
      targetId: product.id,
      plan: plan,
    ),
    onCancelPromotion: () => walletRepository.cancelPromotion(
      targetType: PromotionTargetType.part,
      targetId: product.id,
    ),
  );
}
