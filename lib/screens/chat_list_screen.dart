import 'package:flutter/material.dart';
import '../models/persona.dart';
import 'chat_screen.dart';
import '../widgets/chat_background.dart';
import '../services/theme_service.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeService,
      builder: (context, _) {
        final isDark = themeService.isDarkMode;

        return Scaffold(
          backgroundColor: isDark ? Colors.black : const Color(0xFFF5F5F7),
          drawer: _buildDrawer(isDark),
          appBar: AppBar(
            backgroundColor: isDark ? const Color(0xFF0B0F1A) : Colors.white,
            elevation: isDark ? 0 : 1,
            iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
            title: Text(
              'AI Chat',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {},
              ),
            ],
          ),
          body: ChatBackground(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: personas.length,
              itemBuilder: (context, index) {
                final p = personas[index];
                return _buildChatCard(context, p, isDark);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildDrawer(bool isDark) {
    return Drawer(
      backgroundColor: isDark ? const Color(0xFF0B0F1A) : Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1B1F2D) : Colors.blueAccent,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white24,
                  radius: 30,
                  child: Icon(Icons.person, color: Colors.white, size: 35),
                ),
                SizedBox(height: 10),
                Text(
                  'AI Chat Settings',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: isDark ? Colors.white : Colors.black,
            ),
            title: Text(
              isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
            ),
            trailing: Switch(
              value: !isDark,
              onChanged: (value) => themeService.toggleTheme(),
            ),
            onTap: () => themeService.toggleTheme(),
          ),
        ],
      ),
    );
  }

  Widget _buildChatCard(BuildContext context, Persona p, bool isDark) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ChatScreen(persona: p)),
        );
      },
      child: Container(
        height: 96,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          // Shadow na gumagana sa Light at Dark
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.5)
                  : Colors.grey.withOpacity(0.3),
              blurRadius: 12,
              spreadRadius: 1,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
              ),
              child: Icon(
                Icons.person,
                color: isDark ? Colors.white : Colors.grey.shade600,
                size: 28,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.name,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tap to chat',
                    style: TextStyle(
                      color: isDark ? Colors.grey : Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '1:30 PM',
              style: TextStyle(
                color: isDark ? Colors.grey : Colors.grey.shade500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}