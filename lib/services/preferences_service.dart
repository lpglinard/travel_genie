import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  PreferencesService(this._prefs);

  final SharedPreferences _prefs;

  Locale? get locale {
    final code = _prefs.getString('locale');
    return code != null ? Locale(code) : null;
  }

  Future<void> setLocale(Locale? locale) async {
    if (locale == null) {
      await _prefs.remove('locale');
    } else {
      await _prefs.setString('locale', locale.languageCode);
    }
  }

  ThemeMode get themeMode {
    final dark = _prefs.getBool('darkMode') ?? false;
    return dark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setBool('darkMode', mode == ThemeMode.dark);
  }

  Future<void> saveUserData(String? name, String? email) async {
    if (name != null) {
      await _prefs.setString('name', name);
    } else {
      await _prefs.remove('name');
    }
    if (email != null) {
      await _prefs.setString('email', email);
    } else {
      await _prefs.remove('email');
    }
  }

  Future<void> clearAll() async {
    await _prefs.remove('name');
    await _prefs.remove('email');
    await _prefs.remove('locale');
    await _prefs.remove('darkMode');
  }
}
