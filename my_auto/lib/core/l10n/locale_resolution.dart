import 'package:flutter/material.dart';
import 'package:my_auto/generated/l10n.dart';

/// Resolves the active app locale with English fallback.
Locale resolveAppLocale(Locale? preferred, Iterable<Locale> supported) {
  const fallback = Locale('en');
  if (preferred == null) {
    return _firstSupported(supported, fallback);
  }
  for (final locale in supported) {
    if (locale.languageCode == preferred.languageCode) {
      return locale;
    }
  }
  return _firstSupported(supported, fallback);
}

Locale _firstSupported(Iterable<Locale> supported, Locale fallback) {
  for (final locale in supported) {
    if (locale.languageCode == fallback.languageCode) return locale;
  }
  return supported.isNotEmpty ? supported.first : fallback;
}

/// Supported language codes for settings UI.
const kAppLanguageCodes = ['en', 'ru', 'uz'];

List<Locale> get supportedAppLocales => S.delegate.supportedLocales;
