import 'package:flutter/material.dart';
import 'package:my_auto/core/provider/language/index.dart';
import 'package:provider/provider.dart';

/// Current UI language code (ru / en / uz).
String categoryLanguageCode(BuildContext context) {
  final fromPrefs = context.read<LocaleNotifier>().locale?.languageCode;
  if (fromPrefs != null && fromPrefs.isNotEmpty) return fromPrefs;
  return Localizations.localeOf(context).languageCode;
}
