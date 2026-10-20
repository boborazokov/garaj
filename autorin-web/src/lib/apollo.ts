import { ApolloClient, HttpLink, InMemoryCache } from '@apollo/client'
import { CombinedGraphQLErrors } from '@apollo/client/errors'
import { setContext } from '@apollo/client/link/context'
import { ErrorLink } from '@apollo/client/link/error'
import { Observable } from 'rxjs'
import { GRAPHQL_URL } from './config'
import {
  clearSession,
  getRefreshToken,
  getToken,
  getUser,
  setSession,
} from './auth'

const httpLink = new HttpLink({ uri: GRAPHQL_URL })

const authLink = setContext((_, { headers }) => {
  const token = getToken()
  return {
    headers: {
      ...headers,
      ...(token ? { authorization: `Bearer ${token}` } : {}),
    },
  }
})

let refreshFlight: Promise<boolean> | null = null

function refreshAdminSession() {
  if (!refreshFlight) {
    refreshFlight = (async () => {
      const refreshToken = getRefreshToken()
      const user = getUser()
      if (!refreshToken || !user) return false
      try {
        const response = await fetch(GRAPHQL_URL, {
          method: 'POST',
          headers: { 'content-type': 'application/json' },
          body: JSON.stringify({
            query: `mutation RefreshSession($refreshToken: String!, $deviceId: String!) {
              refreshSession(refreshToken: $refreshToken, deviceId: $deviceId) {
                token
                refreshToken
              }
            }`,
            variables: { refreshToken, deviceId: 'admin-web' },
          }),
        })
        const json = (await response.json()) as {
          data?: { refreshSession?: { token?: string; refreshToken?: string } }
          errors?: { message?: string }[]
        }
        const next = json.data?.refreshSession
        if (!next?.token || !next.refreshToken) {
          const code = json.errors?.[0]?.message ?? ''
          if (code === 'SESSION_REVOKED' || code === 'INVALID_REFRESH_TOKEN') {
            clearSession()
          }
          return false
        }
        setSession(next.token, user, next.refreshToken)
        return true
      } catch {
        return false
      } finally {
        refreshFlight = null
      }
    })()
  }
  return refreshFlight
}

const errorLink = new ErrorLink(({ error, operation, forward }) => {
  if (!CombinedGraphQLErrors.is(error)) return
  const expired = error.errors.some(
    (item) =>
      item.message === 'AUTH_TOKEN_EXPIRED' ||
      item.extensions?.code === 'AUTH_TOKEN_EXPIRED',
  )
  if (!expired || operation.operationName === 'RefreshSession') return
  return new Observable((observer) => {
    refreshAdminSession().then((ok) => {
      if (!ok) {
        observer.error(error)
        return
      }
      forward(operation).subscribe(observer)
    })
  })
})

export const apolloClient = new ApolloClient({
  link: errorLink.concat(authLink).concat(httpLink),
  cache: new InMemoryCache(),
  defaultOptions: {
    watchQuery: { fetchPolicy: 'cache-and-network' },
    query: { fetchPolicy: 'network-only' },
  },
})
