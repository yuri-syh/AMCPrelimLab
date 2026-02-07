import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:share_plus/share_plus.dart'; // Para sa Export
import 'dart:io'; // Para sa File handling
import '../models/chat_message.dart';
import '../models/persona.dart';
import '../widgets/message_bubble.dart';
import '../widgets/input_bar.dart';
import '../services/gemini_service.dart';
import '../services/storage_service.dart';
import '../services/theme_service.dart';

class ChatScreen extends StatefulWidget {
  final Persona persona;
  const ChatScreen({super.key, required this.persona});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<ChatMessage> messages = [];
  bool isLoading = false;
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _loadData();
    _initTTS();
  }

  void _initTTS() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);
  }

  Future<void> _loadData() async {
    final history = await StorageService.loadMessages(widget.persona.name);
    setState(() {
      messages = history;
    });
  }

  Future<void> _speak(String text) async {
    if (text.isNotEmpty) {
      await _flutterTts.speak(text);
    }
  }

  void addMessage(String text, String role) {
    setState(() {
      messages.add(ChatMessage(
        text: text,
        role: role,
        timestamp: DateTime.now(),
      ));
    });
  }

  // --- NEW: EXPORT FUNCTION ---
  Future<void> handleExport() async {
    if (messages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No messages to export!")),
      );
      return;
    }

    try {
      // Gagamit tayo ng StorageService para i-format ang file
      File file = await StorageService.exportToTextFile(widget.persona.name, messages);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'My conversation with ${widget.persona.name}',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Export failed: $e")),
      );
    }
  }

  Future<void> handleSend(String text) async {
    if (text.trim().isEmpty) return;

    if (messages.isEmpty) {
      await StorageService.saveFirstInteraction(widget.persona.name, text);
    }

    final firstChat = await StorageService.loadFirstInteraction(widget.persona.name);

    addMessage(text, "user");
    setState(() => isLoading = true);

    try {
      final aiResponse = await GeminiService.sendMultiTurnMessage(
          messages,
          widget.persona.systemPrompt,
          firstChat
      );

      addMessage(aiResponse, "model");
      await _speak(aiResponse);
      await StorageService.saveMessages(widget.persona.name, messages);
    } catch (e) {
      addMessage('❌ Error: $e', "model");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void deleteHistory() async {
    await _flutterTts.stop();
    setState(() => messages.clear());
    await StorageService.saveMessages(widget.persona.name, []);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("History cleared!"))
      );
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeService,
      builder: (context, _) {
        final isDark = themeService.isDarkMode;

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF0A0E1C) : const Color(0xFFF5F5F7),
          body: Stack(
            children: [
              Column(
                children: [
                  const SizedBox(height: 110),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.only(top: 20, left: 12, right: 12, bottom: 12),
                      itemCount: messages.length,
                      itemBuilder: (_, i) => MessageBubble(message: messages[i]),
                    ),
                  ),
                  if (isLoading)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Thinking...",
                          style: TextStyle(color: isDark ? Colors.grey : Colors.grey.shade700, fontSize: 12)),
                    ),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? Colors.transparent : Colors.white,
                      boxShadow: isDark ? [] : [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))
                      ],
                    ),
                    child: InputBar(onSend: handleSend),
                  ),
                ],
              ),

              // Floating Custom App Bar
              Positioned(
                top: 35,
                left: 0,
                right: 0,
                child: Container(
                  height: 80,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0B0F1A) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: isDark ? Colors.black54 : Colors.grey.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4)
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          _flutterTts.stop();
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1B1F2D) : Colors.grey.shade100,
                              shape: BoxShape.circle
                          ),
                          child: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : Colors.black, size: 18),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.persona.name,
                          style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                      ),
                      // EXPORT BUTTON
                      IconButton(
                        icon: const Icon(Icons.ios_share_rounded, color: Colors.blue),
                        onPressed: handleExport,
                      ),
                      // STOP VOICE BUTTON
                      IconButton(
                        icon: const Icon(Icons.volume_off_rounded, color: Colors.grey),
                        onPressed: () => _flutterTts.stop(),
                      ),
                      GestureDetector(
                        onTap: deleteHistory,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1B1F2D) : Colors.red.shade50,
                              shape: BoxShape.circle
                          ),
                          child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}