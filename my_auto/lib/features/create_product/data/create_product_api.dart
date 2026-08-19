const String getCategoryTreeQuery = r'''
query GetCategoryTree {
  getCategoryTree(rootType: BRAND) {
    _id
    names { en ru uz }
    type
    iconUrl
    children {
      _id
      names { en ru uz }
      type
      iconUrl
      children {
        _id
        names { en ru uz }
        type
        iconUrl
      }
    }
  }
}
''';

const String getPartCategoriesQuery = r'''
query GetPartCategories {
  getCategories(filter: { type: PART }) {
    _id
    names { en ru uz }
    iconUrl
    type
  }
}
''';

const String getModelsForBrandQuery = r'''
query GetModelsForBrand($parentId: ObjectId!) {
  getCategories(filter: { type: MODEL, parentId: $parentId }) {
    _id
    names { en ru uz }
    iconUrl
    type
    parentId
  }
}
''';

const String getAllModelsQuery = r'''
query GetAllModels {
  getCategories(filter: { type: MODEL }) {
    _id
    names { en ru uz }
    iconUrl
    type
    parentId
  }
}
''';

const String createPartMutation = r'''
mutation CreatePart($data: PartInput!, $images: [Upload!]!) {
  createPart(data: $data, images: $images) {
    _id
  }
}
''';

const String updatePartMutation = r'''
mutation UpdatePart($partId: ObjectId!, $data: PartUpdateInput!, $images: [Upload!]) {
  updatePartById(partId: $partId, data: $data, images: $images) {
    _id
  }
}
''';
