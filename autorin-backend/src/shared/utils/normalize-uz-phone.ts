/**
 * Canonical Uzbekistan mobile: +998XXXXXXXXX (12 digits after +).
 * Accepts Telegram contacts (998…), local 9-digit, and E.164 from clients.
 */
export function normalizeUzPhone(raw: string): string {
  const digits = String(raw ?? '').replace(/\D/g, '');

  if (digits.length === 12 && digits.startsWith('998')) {
    return `+${digits}`;
  }

  if (digits.length === 9) {
    return `+998${digits}`;
  }

  return String(raw ?? '').replaceAll(' ', '').trim();
}

/** All common stored variants for a single lookup (legacy rows included). */
export function uzPhoneLookupVariants(raw: string): string[] {
  const canonical = normalizeUzPhone(raw);
  const digitsOnly = canonical.replace(/\D/g, '');
  const trimmed = String(raw ?? '').replaceAll(' ', '').trim();

  return [
    ...new Set(
      [canonical, digitsOnly, `+${digitsOnly}`, trimmed].filter(
        (v) => v.length > 0,
      ),
    ),
  ];
}
