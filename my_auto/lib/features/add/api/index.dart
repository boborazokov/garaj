const String GET_CATEGORIES = r"""
query Query($filter: CategoryFilterInput) {
  getCategories(filter: $filter) {
    _id
    names { en ru uz }
    iconUrl
    icon
    key
  }
}
""";

const String CREATE_PARTS = r"""
mutation Mutation($data: PartInput!, $images: [Upload!]!) {
  createPart(data: $data, images: $images) {
    _id
  }
}
""";

const String CREATE_WORKSHOP = r"""
mutation Mutation($data: WorkshopInput!, $images: [Upload!]!) {
  createWorkshop(data: $data, images: $images) {
    _id
  }
}
 """;

const String UPDATE_WORKSHOP = r"""
mutation Mutation($workshopId: ObjectId!, $data: WorkshopUpdateInput!, $images: [Upload!]) {
  updateWorkshopById(workshopId: $workshopId, data: $data, images: $images) {
    _id
  }
}
""";

const String GET_WORKSHOP_BY_ID = r"""" 
query Query($workshopId: ObjectId!) {
  getWorkshopById(workshopId: $workshopId) {
    _id
    images
    location
    openFrom
    openUntil
  }
}
""";
