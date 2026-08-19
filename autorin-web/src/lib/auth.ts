export type UserRole = 'ADMIN' | 'MODERATOR' | 'USER'

export interface AuthUser {
  _id: string
  name: string
  phone: string
  role: UserRole
}

const TOKEN_KEY = 'autorin_token'
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

export function setSession(token: string, user: AuthUser) {
  localStorage.setItem(TOKEN_KEY, token)
  localStorage.setItem(USER_KEY, JSON.stringify(user))
}

export function clearSession() {
  localStorage.removeItem(TOKEN_KEY)
  localStorage.removeItem(USER_KEY)
}

export function isAdmin(user: AuthUser | null) {
  return user?.role === 'ADMIN'
}

export function isModerator(user: AuthUser | null) {
  return user?.role === 'MODERATOR' || user?.role === 'ADMIN'
}
