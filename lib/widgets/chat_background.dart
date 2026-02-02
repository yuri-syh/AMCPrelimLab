import 'package:flutter/material.dart';

class ChatBackground extends StatelessWidget {
  final Widget child;

  const ChatBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.bottomCenter,
          radius: 1.3,
          colors: [
            Color(0xFF1E2A4A), // blue glow
            Color(0xFF0B0F1A), // dark
            Colors.black,
          ],
        ),
      ),
      child: child,
    );
  }
}
