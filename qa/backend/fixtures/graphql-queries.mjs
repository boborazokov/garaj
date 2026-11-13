/** Shared GraphQL documents for API smoke tests (no secrets). */

export const INTROSPECTION_LITE = `
  query IntrospectionLite {
    __typename
  }
`;

export const SIGN_IN = `
  query SignIn($data: SignInInput!) {
    signIn(data: $data) {
      token
      refreshToken
      user {
        id
        role
        phone
      }
    }
  }
`;

export const HEALTH_HINTS = [
  INTROSPECTION_LITE,
];
