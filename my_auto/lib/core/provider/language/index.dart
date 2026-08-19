import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleNotifier extends ChangeNotifier {
  Locale? _locale;

  Locale? get locale => _locale;

  Future<void> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('languageCode');
    _locale = langCode != null ? Locale(langCode) : null;
    notifyListeners();
  }

  Future<void> setLocale(String languageCode) async {
    _locale = Locale(languageCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', languageCode);
    notifyListeners();
  }

  void clearLocale() async {
    _locale = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('languageCode');
    notifyListeners();
  }
}
