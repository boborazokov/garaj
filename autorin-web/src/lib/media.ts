import { API_URL, FILE_URL } from './config'

/** MinIO path or full MinIO/CDN URL → storage key (bucket/rest). */
export function toStoragePath(path: string): string {
  const trimmed = path.trim()
  if (!trimmed) return ''

  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    try {
      return new URL(trimmed).pathname.replace(/^\//, '')
    } catch {
      return trimmed.replace(/^\//, '')
    }
  }

  const fileBase = FILE_URL.replace(/\/$/, '')
  if (fileBase && trimmed.startsWith(`${fileBase}/`)) {
    return trimmed.slice(fileBase.length + 1)
  }

  return trimmed.replace(/^\//, '')
}

/**
 * Image URL for admin UI. Prefer API media proxy (same host as GraphQL/ngrok).
 * Direct MinIO (VITE_FILE_URL) often breaks when the file tunnel differs or is down.
 */
export function mediaUrl(path?: string | null): string {
  if (!path?.trim()) return ''

  const storagePath = toStoragePath(path)
  if (!storagePath) return ''

  const api = API_URL.replace(/\/$/, '')
  return `${api}/media/${storagePath}`
}
