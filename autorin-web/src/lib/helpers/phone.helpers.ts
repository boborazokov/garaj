export function cleanPhone(value: string = '') {
  return value
    .replace(/\D/g, '')
    .replace(/^998/, '')
    .slice(0, 9)
}

export function formatPhoneNumber(value: string = '') {
  const digits = cleanPhone(value)

  if (!digits) return ''

  if (digits.length <= 2) return digits
  if (digits.length <= 5) return `${digits.slice(0, 2)} ${digits.slice(2)}`
  if (digits.length <= 7) return `${digits.slice(0, 2)} ${digits.slice(2, 5)} ${digits.slice(5)}`

  return `${digits.slice(0, 2)} ${digits.slice(2, 5)} ${digits.slice(5, 7)} ${digits.slice(7)}`
}
