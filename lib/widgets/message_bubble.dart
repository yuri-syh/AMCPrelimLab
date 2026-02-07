import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para sa Clipboard
import 'package:share_plus/share_plus.dart'; // Para sa Share feature
import '../models/chat_message.dart';
import '../services/theme_service.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUserMessage;

    return ListenableBuilder(
      listenable: themeService,
      builder: (context, _) {
        final isDark = themeService.isDarkMode;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Align(
            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 280),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isUser
                    ? const Color(0xFF4C7DAA)
                    : (isDark ? const Color(0xFF2A2A2A) : Colors.white),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: isUser ? const Radius.circular(18) : Radius.zero,
                  bottomRight: isUser ? Radius.zero : const Radius.circular(18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  // SelectableText para pwedeng i-highlight ang part ng text
                  SelectableText(
                    message.text,
                    style: TextStyle(
                      color: isUser ? Colors.white : (isDark ? Colors.white : Colors.black),
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ICON: COPY
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: message.text));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Copied!"), duration: Duration(seconds: 1)),
                          );
                        },
                        child: Icon(
                          Icons.copy_rounded,
                          size: 16,
                          color: isUser ? Colors.white70 : Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // ICON: SHARE
                      GestureDetector(
                        onTap: () {
                          Share.share(message.text);
                        },
                        child: Icon(
                          Icons.share_rounded,
                          size: 16,
                          color: isUser ? Colors.white70 : Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // TIME
                      Text(
                        _formatTime(message.timestamp),
                        style: TextStyle(
                          fontSize: 10,
                          color: isUser ? Colors.white70 : (isDark ? Colors.grey : Colors.black45),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
}