const String UPDATE_PROFILE = r"""
mutation Mutation($data: UserUpdateInput!, $image: Upload) {
  updateProfile(data: $data, image: $image) {
    _id
    name
    phone
    image
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
  }
}
""";
