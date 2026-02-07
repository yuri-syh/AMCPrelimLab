import 'package:flutter/material.dart';
import 'screens/chat_list_screen.dart';
import 'services/theme_service.dart';

void main() {
  runApp(const ChatApp());
}

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const ChatListScreen(),
    );
  }
}
