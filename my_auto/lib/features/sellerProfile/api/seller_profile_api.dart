const String GET_SELLER_PROFILE = r"""
query GetSellerProfile($sellerId: ObjectId!) {
  getSellerProfile(sellerId: $sellerId) {
    _id
    name
    username
    image
    banner
    bio
    description
    phone
    email
    country
    region
    city
    address
    verified
    createdAt
    isFollowing
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
      followersCount
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

const String FOLLOW_SELLER = r"""
mutation FollowSeller($sellerId: ObjectId!) {
  followSeller(sellerId: $sellerId)
}
""";

const String UNFOLLOW_SELLER = r"""
mutation UnfollowSeller($sellerId: ObjectId!) {
  unfollowSeller(sellerId: $sellerId)
}
""";

const String GET_SELLER_FOLLOWERS = r'''
query GetSellerFollowers($sellerId: ObjectId!, $pagination: PaginationInput) {
  getSellerFollowers(sellerId: $sellerId, pagination: $pagination) {
    totalDocs
    hasNextPage
    payload {
      _id
      name
      username
      image
      followedAt
    }
  }
}
''';

const String GET_PROFILE = r"""
query GetProfile {
  getProfile {
    _id
    name
    phone
    image
    banner
    username
    bio
    description
    email
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
      showFollowers
      allowMessages
    }
    createdAt
  }
}
""";
