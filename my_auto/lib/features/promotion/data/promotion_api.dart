const String promotionPlanPricesQuery = r'''
query PromotionPlanPrices {
  promotionPlanPrices {
    plan
    amount
    currency
    days
    priority
  }
}
''';

const String purchasePromotionMutation = r'''
mutation PurchasePromotion(
  $targetType: PromotionTargetTypeEnum!
  $targetId: ObjectId!
  $plan: ServicePromotionPlanEnum!
) {
  purchasePromotion(
    targetType: $targetType
    targetId: $targetId
    plan: $plan
  ) {
    _id
    status
    plan
    amount
    currency
    paidAt
    promotedAt
    failureReason
  }
}
''';
