import 'dart:io';
import 'package:flutter/foundation.dart'; // Import ito para sa kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../models/chat_message.dart';
import '../services/theme_service.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUserMessage;
    final isDark = themeService.isDarkMode;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // IMAGE DISPLAY LOGIC (Web vs Mobile)
            if (message.imagePath != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: kIsWeb
                      ? Image.network(
                    message.imagePath!, // Sa Web, ang path ay Blob URL
                    width: 220,
                    fit: BoxFit.cover,
                  )
                      : Image.file(
                    File(message.imagePath!), // Sa Mobile, ito ay File Path
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
                  SelectableText(
                    message.text,
                    style: TextStyle(
                      color: isUser || isDark ? Colors.white : Colors.black,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // COPY ICON
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: message.text));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Copied!"), duration: Duration(seconds: 1)),
                          );
                        },
                        child: Icon(Icons.copy_rounded, size: 14, color: isUser ? Colors.white70 : Colors.grey),
                      ),
                      const SizedBox(width: 12),
                      // SHARE ICON
                      GestureDetector(
                        onTap: () => Share.share(message.text),
                        child: Icon(Icons.share_rounded, size: 14, color: isUser ? Colors.white70 : Colors.grey),
                      ),
                      const SizedBox(width: 12),
                      // TIMESTAMP
                      Text(
                        '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 10,
                          color: isUser ? Colors.white70 : Colors.grey,
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
    );
  }
}