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
          drawer: _buildDrawer(isDark, lang),
          body: ChatBackground(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 120.0,
                  floating: true,
                  pinned: true,
                  stretch: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    title: Text(
                      lang.translate('app_title'),
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        fontSize: 22,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  leading: Builder(
                    builder: (context) => IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.menu_rounded,
                            color: isDark ? Colors.white : Colors.black, size: 20),
                      ),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
                ),

                // Chat List
                SliverPadding(
                  padding: const EdgeInsets.only(top: 10, bottom: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        return _buildChatCard(
                          context,
                          personas[index],
                          isDark,
                          lang,
                        );
                      },
                      childCount: personas.length,
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
  Widget _buildChatCard(BuildContext context, Persona p, bool isDark, LanguageService lang) {
    return FutureBuilder<List<ChatMessage>>(
      future: StorageService.loadMessages(p.name),
      builder: (context, snapshot) {
        String displayTime = "";
        String lastMessagePreview = lang.translate('tap_to_chat');
        bool hasChat = snapshot.hasData && snapshot.data!.isNotEmpty;

        if (hasChat) {
          final lastMsg = snapshot.data!.last;
          displayTime = _formatTime(lastMsg.timestamp);
          final sender = lastMsg.role == "user" ? "You: " : "";
          lastMessagePreview = "$sender${lastMsg.text}";
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(persona: p)));
              setState(() {});
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? Colors.white.withOpacity(0.08) : Colors.transparent,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Avatar with status indicator
                  Stack(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Colors.blueAccent, Colors.purpleAccent.withOpacity(0.5)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueAccent.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(2), // Border effect
                          child: CircleAvatar(
                            backgroundImage: AssetImage(p.imagePath),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),

                  // Name and Message
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              p.name,
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (displayTime.isNotEmpty)
                              Text(
                                displayTime,
                                style: TextStyle(
                                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                                  fontSize: 11,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          lastMessagePreview,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black54,
                            fontSize: 14,
                            fontStyle: hasChat ? FontStyle.normal : FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: isDark ? Colors.white24 : Colors.black12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDrawer(bool isDark, LanguageService lang) {
    return Drawer(
      backgroundColor: isDark ? const Color(0xFF0B0F1A) : Colors.white,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1B1F2D), const Color(0xFF0B0F1A)]
                    : [Colors.blueAccent, Colors.lightBlue],
              ),
            ),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white24,
              child: Icon(Icons.auto_awesome, color: Colors.white, size: 30),
            ),
            accountName: const Text("Gen AI Explorer", style: TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: null,
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