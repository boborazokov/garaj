import 'package:flutter/material.dart';
import 'package:my_auto/features/promotion/presentation/promote_plan_sheet.dart';
import 'package:my_auto/features/workshop/data/models/workshop_profile.dart';
import 'package:my_auto/features/workshop/data/workshops_repository.dart';
import 'package:my_auto/generated/l10n.dart';

Future<bool?> showPromoteWorkshopSheet(
  BuildContext context, {
  required WorkshopProfile workshop,
}) {
  return showPromotePlanSheet(
    context,
    listingTitle: workshop.name,
    isPromotionActive: workshop.isPromotionActive,
    activePlan: workshop.promotionPlan,
    sheetTitle: S.of(context).promoteWorkshopTitle,
    onPromote: (plan) => workshopsRepository.promoteWorkshop(
      workshopId: workshop.id,
      plan: plan,
    ),
  );
}

Future<bool?> showPromoteWorkshopByIdSheet(
  BuildContext context, {
  required String workshopId,
  required String title,
}) async {
  final profile = await workshopsRepository.details(workshopId);
  if (!context.mounted || profile == null) return null;
  return showPromoteWorkshopSheet(context, workshop: profile);
}
