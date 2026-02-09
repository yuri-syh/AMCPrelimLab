import 'package:flutter/material.dart';
import '../models/persona.dart';
import '../models/chat_message.dart';
import 'chat_screen.dart';
import '../widgets/chat_background.dart';
import '../services/theme_service.dart';
import '../services/language_service.dart';
import '../services/storage_service.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  // Time
  String _formatTime(DateTime dateTime) {
    int hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    if (hour == 0) hour = 12;
  // Padleft
    String minute = dateTime.minute.toString().padLeft(2, '0');
    String period = dateTime.hour >= 12 ? "PM" : "AM";
    return "$hour:$minute $period";
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([themeService, languageService]),
      builder: (context, _) {
        final isDark = themeService.isDarkMode;
        final lang = languageService;

        return Scaffold(
          backgroundColor: isDark ? Colors.black : const Color(0xFFF5F5F7),
          drawer: _buildDrawer(isDark, lang),
          appBar: AppBar(
            backgroundColor: isDark ? const Color(0xFF0B0F1A) : Colors.white,
            elevation: isDark ? 0 : 1,
            leading: Builder(
              builder: (context) => IconButton(
                icon: Icon(Icons.settings,
                    color: isDark ? Colors.white : Colors.black),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
            title: Text(
              lang.translate('app_title'),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
          body: ChatBackground(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: personas.length,
              itemBuilder: (context, index) {
                return _buildChatCard(
                  context,
                  personas[index],
                  isDark,
                  lang,
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildChatCard(
      BuildContext context,
      Persona p,
      bool isDark,
      LanguageService lang,
      ) {
    // last message and time
    return FutureBuilder<List<ChatMessage>>(
      future: StorageService.loadMessages(p.name),
      builder: (context, snapshot) {
        String displayTime = "";
        String lastMessagePreview = lang.translate('tap_to_chat');
        bool hasChat = snapshot.hasData && snapshot.data!.isNotEmpty;

        if (hasChat) {
          final lastMsg = snapshot.data!.last;
          displayTime = _formatTime(lastMsg.timestamp);
          final sender = lastMsg.role == "user" ? "You: " : "${p.name}: ";
          lastMessagePreview = "$sender${lastMsg.text}";
        }

        return InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatScreen(persona: p),
              ),
            );
            setState(() {});
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.45 : 0.15),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage(p.imagePath),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.name,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        lastMessagePreview,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isDark
                              ? Colors.grey.shade300
                              : Colors.grey.shade700,
                          fontSize: 14,
                          height: 1.3,
                          fontStyle:
                          hasChat ? FontStyle.normal : FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                if (displayTime.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      displayTime,
                      style: TextStyle(
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDrawer(bool isDark, LanguageService lang) {
    return Drawer(
      backgroundColor: isDark ? const Color(0xFF0B0F1A) : Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1B1F2D) : Colors.blueAccent,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.star, size: 42, color: Colors.white),
                // Binaba ang text gamit ang mas malaking height
                SizedBox(height: 35),
                Text(
                  'Gen AI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Theme Toggle Section
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
              onChanged: (_) => themeService.toggleTheme(),
            ),
            onTap: themeService.toggleTheme,
          ),

          // About AI Section
          ListTile(
            leading: Icon(
              Icons.info_outline,
              color: isDark ? Colors.white : Colors.black,
            ),
            title: Text(
              'About AI',
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: isDark ? const Color(0xFF1B1F2D) : Colors.white,
                  title: Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: Colors.blueAccent),
                      const SizedBox(width: 10),
                      Text(
                        "Gen AI Chat",
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  content: Text(
                    "Gen AI is a general-purpose AI assistant designed to help answer questions and support users with everyday tasks.\n\n"
                        "This AI may produce inaccurate information. Users are encouraged to verify important details.",
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Close",
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const Divider(),
        ],
      ),
    );
  }
}