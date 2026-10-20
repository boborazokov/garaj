export type UserRole = 'ADMIN' | 'MODERATOR' | 'USER'

export interface AuthUser {
  _id: string
  name: string
  phone: string
  role: UserRole
}

const TOKEN_KEY = 'autorin_token'
const REFRESH_KEY = 'autorin_refresh'
const USER_KEY = 'autorin_user'

export function getToken(): string | null {
  return localStorage.getItem(TOKEN_KEY)
}

export function getUser(): AuthUser | null {
  const raw = localStorage.getItem(USER_KEY)
  if (!raw) return null
  try {
    return JSON.parse(raw) as AuthUser
  } catch {
    return null
  }
}

export function getRefreshToken(): string | null {
  return localStorage.getItem(REFRESH_KEY)
}

export function setSession(
  token: string,
  user: AuthUser,
  refreshToken?: string | null,
) {
  localStorage.setItem(TOKEN_KEY, token)
  localStorage.setItem(USER_KEY, JSON.stringify(user))
  if (refreshToken) localStorage.setItem(REFRESH_KEY, refreshToken)
}

export function clearSession() {
  localStorage.removeItem(TOKEN_KEY)
  localStorage.removeItem(REFRESH_KEY)
  localStorage.removeItem(USER_KEY)
}

export function isAdmin(user: AuthUser | null) {
  return user?.role === 'ADMIN'
}

export function isModerator(user: AuthUser | null) {
  return user?.role === 'MODERATOR' || user?.role === 'ADMIN'
}
