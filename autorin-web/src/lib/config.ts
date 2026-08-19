export const API_URL = import.meta.env.VITE_API_URL ?? 'http://localhost:7007'
export const FILE_URL = import.meta.env.VITE_FILE_URL ?? 'http://localhost:9011'
export const GRAPHQL_URL = `${API_URL.replace(/\/$/, '')}/api`
