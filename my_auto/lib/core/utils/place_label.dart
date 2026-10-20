/// Helpers to show human place names instead of raw coordinates.
library;

final _coordPair = RegExp(
  r'^-?\d{1,3}([.,]\d+)?\s*,\s*-?\d{1,3}([.,]\d+)?$',
);

final _singleCoord = RegExp(r'^-?\d{1,3}([.,]\d{2,})?$');

final _pointWkt = RegExp(
  r'point\s*\(',
  caseSensitive: false,
);

/// True when [value] looks like `"41.29950, 69.24010"` or similar.
bool looksLikeCoordinates(String? value) {
  final t = value?.trim() ?? '';
  if (t.isEmpty) return false;
  if (_coordPair.hasMatch(t)) return true;
  if (_pointWkt.hasMatch(t)) return true;
  // Lone latitude/longitude fragment — not a city name.
  if (_singleCoord.hasMatch(t) && t.contains(RegExp(r'[.,]'))) return true;
  return false;
}

bool _isPlaceholder(String value) {
  final t = value.trim();
  if (t.isEmpty) return true;
  if (RegExp(r'^[-–—._\s]+$').hasMatch(t)) return true;
  final lower = t.toLowerCase();
  if (lower == 'null' || lower == 'undefined' || lower == 'n/a') return true;
  return false;
}

/// Prefer street/address, then city / region, then non-coordinate location.
String humanPlaceLabel({
  String? address,
  String? city,
  String? location,
  String? region,
  String fallback = '—',
}) {
  for (final candidate in [address, city, region, location]) {
    final t = candidate?.trim() ?? '';
    if (_isPlaceholder(t)) continue;
    if (looksLikeCoordinates(t)) continue;
    return t;
  }
  return fallback;
}

/// Compact `dd.MM` for card footers.
String formatDayMonth(DateTime dt) {
  final local = dt.toLocal();
  final d = local.day.toString().padLeft(2, '0');
  final m = local.month.toString().padLeft(2, '0');
  return '$d.$m';
}

/// Viloyat only. Street text typed into Manzil stays off the card.
String regionOnlyLabel(String? region) {
  final t = region?.trim() ?? '';
  if (_isPlaceholder(t) || looksLikeCoordinates(t)) return '';
  return t;
}

/// Today → `Bugun`. Any earlier calendar day → `8 sentabr`.
String cardPostedLabel(DateTime dt, {required String languageCode}) {
  final local = dt.toLocal();
  final now = DateTime.now();
  if (local.year == now.year &&
      local.month == now.month &&
      local.day == now.day) {
    switch (languageCode) {
      case 'ru':
        return 'Сегодня';
      case 'en':
        return 'Today';
      default:
        return 'Bugun';
    }
  }
  return '${local.day} ${_monthName(local.month, languageCode)}';
}

String _monthName(int month, String languageCode) {
  const uz = [
    'yanvar',
    'fevral',
    'mart',
    'aprel',
    'may',
    'iyun',
    'iyul',
    'avgust',
    'sentabr',
    'oktabr',
    'noyabr',
    'dekabr',
  ];
  const ru = [
    'января',
    'февраля',
    'марта',
    'апреля',
    'мая',
    'июня',
    'июля',
    'августа',
    'сентября',
    'октября',
    'ноября',
    'декабря',
  ];
  const en = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  final names = switch (languageCode) {
    'en' => en,
    'ru' => ru,
    _ => uz,
  };
  final index = month.clamp(1, 12) - 1;
  return names[index];
}
