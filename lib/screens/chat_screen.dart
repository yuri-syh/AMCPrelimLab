import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';
import '../models/persona.dart';
import '../widgets/message_bubble.dart';
import '../widgets/input_bar.dart';
import '../services/gemini_service.dart';
import '../services/storage_service.dart';
import '../services/theme_service.dart';
import 'dart:convert';
import 'dart:ui';

class ChatScreen extends StatefulWidget {
  final Persona persona;
  const ChatScreen({super.key, required this.persona});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<ChatMessage> messages = [];
  bool isLoading = false;
  bool isMuted = false;
  final FlutterTts _flutterTts = FlutterTts();

  XFile? selectedImage;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) selectedImage = null;
    _loadData();
    _initTTS();
  }

  void _initTTS() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.8);
  }

  // history
  Future<void> _loadData() async {
    final history =
    await StorageService.loadMessages(widget.persona.name);
    setState(() => messages = history);
  }

  Future<void> _speak(String text) async {
    if (!isMuted && text.isNotEmpty) {
      await _flutterTts.speak(text);
    }
  }

  void addMessage(String text, String role, {String? imagePath}) {
    setState(() {
      messages.add(ChatMessage(
        text: text,
        role: role,
        timestamp: DateTime.now(),
        imagePath: imagePath,
      ));
    });
  }

  Future<void> handleSend(String text, XFile? imageFile) async {
    if (text.trim().isEmpty && imageFile == null) return;
    if (messages.isEmpty && text.isNotEmpty) {
      await StorageService.saveFirstInteraction(widget.persona.name, text);
    }
    final firstChat = await StorageService.loadFirstInteraction(widget.persona.name);

    String? imageToSave;
    if (imageFile != null) {
      if (kIsWeb) {
        final bytes = await imageFile.readAsBytes();
        imageToSave = base64Encode(bytes);
      } else {
        imageToSave = imageFile.path;
      }
    }


    addMessage(text, "user", imagePath: imageToSave);
    setState(() => isLoading = true);

    try {
      final aiResponse = await GeminiService.sendMultiTurnMessage(
        messages,
        widget.persona.systemPrompt,
        firstChat,
        imageFile: imageFile,
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
    await StorageService.saveMessages(
        widget.persona.name, []);
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
          backgroundColor:
          isDark ? const Color(0xFF0A0E1C) : const Color(0xFFF5F5F7),
          body: Stack(
            children: [
              // CHAT BODY
              Column(
                children: [
                  const SizedBox(height: 125),
                  Expanded(
                    child: ListView.builder(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: messages.length,
                      itemBuilder: (_, i) => MessageBubble(
                        message: messages[i],
                        persona: widget.persona,
                      ),
                    ),
                  ),
                  if (isLoading)
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        "Thinking...",
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? Colors.grey
                              : Colors.black54,
                        ),
                      ),
                    ),
                  Container(
                    color:
                    isDark ? Colors.transparent : Colors.white,
                    child: InputBar(onSend: handleSend),
                  ),
                ],
              ),

              //HEADER / BACK
              Positioned(
                top: 35,
                left: 16,
                right: 16,
                child: Container(
                  height: 80,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF0B0F1A)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios_new,
                          color: isDark
                              ? Colors.white
                              : Colors.black,
                        ),
                        onPressed: () =>
                            Navigator.pop(context),
                      ),

                      CircleAvatar(
                        radius: 18,
                        backgroundImage: AssetImage(
                            widget.persona.imagePath),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          widget.persona.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),

                      IconButton(
                        icon: Icon(
                          isMuted
                              ? Icons.volume_off
                              : Icons.volume_up,
                          color: isMuted
                              ? Colors.grey
                              : Colors.green,
                        ),
                        onPressed: () {
                          setState(
                                  () => isMuted = !isMuted);
                          if (!isMuted &&
                              messages.isNotEmpty &&
                              messages.last.role ==
                                  "model") {
                            _speak(messages.last.text);
                          } else {
                            _flutterTts.stop();
                          }
                        },
                      ),

                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: deleteHistory,
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
