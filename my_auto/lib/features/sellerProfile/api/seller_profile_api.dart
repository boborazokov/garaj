const String GET_SELLER_PROFILE = r"""
query GetSellerProfile($sellerId: ObjectId!) {
  getSellerProfile(sellerId: $sellerId) {
    _id
    name
    image
    banner
    phone
    country
    region
    city
    address
    verified
    createdAt
    isOwnProfile
    allowMessages
    socialLinks {
      telegram
      instagram
      website
      youtube
      facebook
    }
    stats {
      totalProducts
      activeProducts
      categoriesCount
      profileViews
    }
    categories {
      categoryId
      name
      slug
      productCount
    }
  }
}
""";

const String GET_PROFILE = r"""
query GetProfile {
  getProfile {
    _id
    name
    phone
    image
    banner
    country
    region
    city
    address
    socialLinks {
      telegram
      instagram
      website
      youtube
      facebook
    }
    privacy {
      showPhone
      showEmail
      showLocation
      allowMessages
    }
    createdAt
  }
}
""";
