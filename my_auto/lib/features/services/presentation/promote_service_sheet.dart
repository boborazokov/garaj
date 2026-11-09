import 'package:flutter/material.dart';
import 'package:my_auto/features/promotion/data/promotion_repository.dart'
    show PromotionTargetType;
import 'package:my_auto/features/promotion/presentation/promote_plan_sheet.dart';
import 'package:my_auto/features/services/data/models/service_listing.dart';
import 'package:my_auto/features/services/data/services_repository.dart';
import 'package:my_auto/features/wallet/data/wallet_repository.dart';
import 'package:my_auto/generated/l10n.dart';

Future<bool?> showPromoteServiceSheet(
  BuildContext context, {
  required ServiceListing service,
}) {
  return showPromotePlanSheet(
    context,
    listingTitle: service.title,
    isPromotionActive: service.isPromotionActive,
    activePlan: service.promotionPlan,
    promotedUntil: service.promotedUntil,
    sheetTitle: S.of(context).promoteServiceTitle,
    onPromote: (plan) => servicesRepository.promoteService(
      serviceId: service.id,
      plan: plan,
    ),
    onCancelPromotion: () => walletRepository.cancelPromotion(
      targetType: PromotionTargetType.service,
      targetId: service.id,
    ),
  );
}
