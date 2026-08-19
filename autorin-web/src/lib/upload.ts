import { API_URL } from './config'
import { getToken } from './auth'

async function postFile(path: string, file: File): Promise<string> {
  const formData = new FormData()
  formData.append('file', file)

  const token = getToken()
  const res = await fetch(`${API_URL.replace(/\/$/, '')}${path}`, {
    method: 'POST',
    headers: token ? { Authorization: `Bearer ${token}` } : {},
    body: formData,
  })

  const body = await res.text()
  let data: { files?: string[]; message?: string | string[] } = {}
  try {
    data = JSON.parse(body) as typeof data
  } catch {
    /* non-json */
  }

  if (!res.ok) {
    const msg =
      typeof data.message === 'string'
        ? data.message
        : Array.isArray(data.message)
          ? data.message.join(', ')
          : body || `Upload failed (${res.status})`
    throw new Error(msg)
  }

  const url = data.files?.[0]
  if (!url) throw new Error('Upload returned no file URL')
  return url
}

export function uploadCategoryIcon(file: File): Promise<string> {
  return postFile('/upload/category-icon', file)
}

export function uploadAdvertisementBanner(file: File): Promise<string> {
  return postFile('/upload/advertisement-banner', file)
}
