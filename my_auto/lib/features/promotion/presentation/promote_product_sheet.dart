import 'package:flutter/material.dart';
import 'package:my_auto/core/model/product/index.dart';
import 'package:my_auto/core/repository/part_repository/index.dart';
import 'package:my_auto/features/promotion/presentation/promote_plan_sheet.dart';
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
    sheetTitle: S.of(context).promoteProductTitle,
    onPromote: (plan) => partRepository.promotePart(
      partId: product.id,
      plan: plan,
    ),
  );
}
