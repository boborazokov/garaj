/// Localized category labels (ru / en / uz).
class CategoryNames {
  const CategoryNames({
    required this.en,
    required this.ru,
    required this.uz,
  });

  final String en;
  final String ru;
  final String uz;

  factory CategoryNames.fromJson(
    dynamic json, {
    String? legacyName,
  }) {
    if (json is Map) {
      return CategoryNames(
        en: _trim(json['en']),
        ru: _trim(json['ru']),
        uz: _trim(json['uz']),
      );
    }
    final s = (legacyName ?? json?.toString() ?? '').trim();
    if (s.isEmpty) {
      return const CategoryNames(en: '—', ru: '—', uz: '—');
    }
    return CategoryNames(en: s, ru: s, uz: s);
  }

  /// Active app language from [LocaleNotifier] or [Localizations].
  String forLocale(String? languageCode) {
    final code = (languageCode ?? 'ru').toLowerCase().split('-').first;
    switch (code) {
      case 'uz':
        return _pick(uz, ru, en);
      case 'en':
        return _pick(en, ru, uz);
      default:
        return _pick(ru, en, uz);
    }
  }

  static String _trim(dynamic v) => v?.toString().trim() ?? '';

  static String _pick(String a, String b, String c) {
    if (a.isNotEmpty) return a;
    if (b.isNotEmpty) return b;
    return c.isNotEmpty ? c : '—';
  }

  /// Shorter label for cards / chips (keeps layout stable).
  String compactForLocale(String? languageCode, {int maxChars = 22}) {
    final full = forLocale(languageCode);
    if (full.length <= maxChars) return full;
    return '${full.substring(0, maxChars).trimRight()}…';
  }
}
