import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../models/chat_message.dart';
import '../models/persona.dart';
import '../services/theme_service.dart';
import 'dart:convert';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final Persona? persona;

  const MessageBubble({
    super.key,
    required this.message,
    this.persona,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUserMessage;
    final isDark = themeService.isDarkMode;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        mainAxisAlignment:
        isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI AVATAR
          if (!isUser)
            Padding(
              padding: const EdgeInsets.only(right: 8, top: 4),
              child: CircleAvatar(
                radius: 16,
                backgroundImage:
                persona != null ? AssetImage(persona!.imagePath) : null,
                backgroundColor: Colors.grey.shade300,
              ),
            ),

          // MESSAGE CONTENT
          Flexible(
            child: Column(
              crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // IMAGE MESSAGE
                if (message.imagePath != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: kIsWeb
                          ? (message.imagePath!.startsWith('data:image') || !message.imagePath!.contains('blob:')
                          ? Image.memory(
                        base64Decode(message.imagePath!), // Decode ang Base64
                        width: 220,
                        fit: BoxFit.cover,
                      )
                          : Image.network(message.imagePath!, width: 220)) // Fallback sa old blob
                          : Image.file(
                        File(message.imagePath!),
                        width: 220,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                // TEXT BUBBLE
                Container(
                  constraints: const BoxConstraints(maxWidth: 280),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isUser
                        ? const Color(0xFF4C7DAA)
                        : (isDark
                        ? const Color(0xFF2A2A2A)
                        : Colors.white),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft:
                      isUser ? const Radius.circular(18) : Radius.zero,
                      bottomRight:
                      isUser ? Radius.zero : const Radius.circular(18),
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
                    crossAxisAlignment: isUser
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      SelectableText(
                        message.text,
                        style: TextStyle(
                          color:
                          isUser || isDark ? Colors.white : Colors.black,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(
                                  ClipboardData(text: message.text));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Copied!"),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                            child: Icon(
                              Icons.copy_rounded,
                              size: 14,
                              color:
                              isUser ? Colors.white70 : Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () => Share.share(message.text),
                            child: Icon(
                              Icons.share_rounded,
                              size: 14,
                              color:
                              isUser ? Colors.white70 : Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              fontSize: 10,
                              color:
                              isUser ? Colors.white70 : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 👤 USER AVATAR (RIGHT)
          if (isUser)
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 4),
              child: const CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xFF4C7DAA),
                child: Icon(
                  Icons.person,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
