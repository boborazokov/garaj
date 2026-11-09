const String myWalletQuery = r'''
query MyWallet {
  myWallet {
    _id
    mainBalance
    bonusBalance
    availableTotal
    currency
  }
}
''';

const String myWalletTransactionsQuery = r'''
query MyWalletTransactions($limit: Int, $cursor: ObjectId) {
  myWalletTransactions(limit: $limit, cursor: $cursor) {
    _id
    type
    pool
    amount
    balanceAfterMain
    balanceAfterBonus
    status
    currency
    referenceType
    referenceId
    note
    metaJson
    createdAt
  }
}
''';

const String createWalletTopupIntentMutation = r'''
mutation CreateWalletTopupIntent($amount: Int!) {
  createWalletTopupIntent(amount: $amount) {
    _id
    type
    pool
    amount
    balanceAfterMain
    balanceAfterBonus
    status
    createdAt
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
    amount
    failureReason
  }
}
''';

const String cancelPromotionMutation = r'''
mutation CancelPromotion(
  $targetType: PromotionTargetTypeEnum!
  $targetId: ObjectId!
) {
  cancelPromotion(targetType: $targetType, targetId: $targetId)
}
''';

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
