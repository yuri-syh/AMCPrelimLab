import 'package:flutter/material.dart';
import '../services/theme_service.dart';

class ChatBackground extends StatelessWidget {
  final Widget child;

  const ChatBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeService,
      builder: (context, _) {
        final isDark = themeService.isDarkMode;

        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.bottomCenter,
              radius: 1.3,
              colors: isDark
                  ? [
                const Color(0xFF1E2A4A), // Blue glow for Dark Mode
                const Color(0xFF0B0F1A),
                Colors.black,
              ]
                  : [
                const Color(0xFFE0E5EC), // Light gray/blue glow for Light Mode
                const Color(0xFFF5F5F7),
                Colors.white,
              ],
            ),
          ),
          child: child,
        );
      },
    );
  }
}