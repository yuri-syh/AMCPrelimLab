import 'package:flutter/material.dart';

class ThemeService extends ChangeNotifier {

  // Default Dark Mode
  bool _isDarkMode = true;
  bool get isDarkMode => _isDarkMode;

  ThemeData get currentTheme => _isDarkMode ? ThemeData.dark().copyWith(
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF0B0F1A), elevation: 0),
    cardColor: const Color(0xFF2A2A2A),
  ) : ThemeData.light().copyWith(
    scaffoldBackgroundColor: const Color(0xFFF5F5F7),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 1,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
    ),
    cardColor: Colors.white,
  );

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}

final themeService = ThemeService();