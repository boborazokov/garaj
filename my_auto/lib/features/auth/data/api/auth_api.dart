const String signUpMutation = r"""
mutation SignUp($data: SignUpInput!) {
  signUp(data: $data) {
    token
    correctCode
  }
}""";

const String confirmSignUpMutation = r"""
mutation ConfirmSignUp($token: String!, $code: String!) {
  confirmSignUp(token: $token, code: $code) {
    token
    accessToken
    refreshToken
    sessionId
    tokenVersion
    user {
      phone
      name
      _id
      image
    }
  }
}
""";

const String signInQuery = r"""
query SignIn($data: SignInInput!) {
  signIn(data: $data) {
    token
    accessToken
    refreshToken
    sessionId
    tokenVersion
    user {
      name
      phone
      _id
      image
    }
  }
}
""";

const String refreshSessionMutation = r"""
mutation RefreshSession($refreshToken: String!, $deviceId: String!) {
  refreshSession(refreshToken: $refreshToken, deviceId: $deviceId) {
    accessToken
    refreshToken
    sessionId
    tokenVersion
    user {
      name
      phone
      _id
      image
    }
  }
}
""";

const String logoutSessionMutation = r"""
mutation LogoutSession($refreshToken: String!, $sessionId: String) {
  logoutSession(refreshToken: $refreshToken, sessionId: $sessionId) {
    success
  }
}
""";

const String logoutAllDevicesMutation = r"""
mutation LogoutAllDevices {
  logoutAllDevices {
    success
  }
}
""";
