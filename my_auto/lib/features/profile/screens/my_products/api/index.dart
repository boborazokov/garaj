const String deletePartById = r"""
mutation Mutation($partId: ObjectId!) {
  deletePartById(partId: $partId) {
    _id
  }
}
 """;

const String updatePartById = r"""
mutation Mutation($partId: ObjectId!, $data: PartUpdateInput!, $images: [Upload!]) {
  updatePartById(partId: $partId, data: $data, images: $images) {
    _id
  }
}
""";

const String RESTORE_PART_BY_ID = r"""
mutation Mutation($partId: ObjectId!) {
  restorePartById(partId: $partId) {
    _id
  }
}
""";

const String promotePartByIdMutation = r"""
mutation PromotePartById($partId: ObjectId!, $plan: ServicePromotionPlanEnum!) {
  promotePartById(partId: $partId, plan: $plan) {
    _id
    isPromoted
    promotedUntil
    promotionPlan
    promotionPriority
  }
}
""";
