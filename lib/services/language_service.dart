import 'package:flutter/material.dart';

enum AppLanguage { en, tl }

class LanguageService extends ChangeNotifier {
  AppLanguage _currentLanguage = AppLanguage.en;
  AppLanguage get currentLanguage => _currentLanguage;

  static final Map<AppLanguage, Map<String, String>> _localizedValues = {
    AppLanguage.en: {
      'app_title': 'AI Chat',
      'settings': 'AI Chat Settings',
      'switch_lang': 'Switch to Tagalog',
      'dark_mode': 'Dark Mode',
      'light_mode': 'Light Mode',
      'tap_to_chat': 'Tap to chat',
      'thinking': 'Thinking...',
      'search': 'Search',
      'no_memory': 'No previous interaction yet.',
      'export_msg': 'My conversation with',
      'delete_history': 'Clear History',
    },
    AppLanguage.tl: {
      'app_title': 'AI Usapan',
      'settings': 'Ayos ng AI Chat',
      'switch_lang': 'Palitan sa English',
      'dark_mode': 'Gawing Dark Mode',
      'light_mode': 'Gawing Light Mode',
      'tap_to_chat': 'Pindutin para mag-chat',
      'thinking': 'Nag-iisip...',
      'search': 'Maghanap',
      'no_memory': 'Wala pang nakaraang usapan.',
      'export_msg': 'Ang usapan ko kasama si',
      'delete_history': 'Burahin ang History',
    },
  };

  String translate(String key) => _localizedValues[_currentLanguage]?[key] ?? key;

  void toggleLanguage() {
    _currentLanguage = (_currentLanguage == AppLanguage.en) ? AppLanguage.tl : AppLanguage.en;
    notifyListeners();
  }
}

final languageService = LanguageService();