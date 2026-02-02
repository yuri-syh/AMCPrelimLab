import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../models/persona.dart';
import '../widgets/message_bubble.dart';
import '../widgets/input_bar.dart';
import '../services/gemini_service.dart';
import '../services/storage_service.dart';

class ChatScreen extends StatefulWidget {
  final Persona persona;
  const ChatScreen({super.key, required this.persona});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<ChatMessage> messages = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final history = await StorageService.loadMessages(widget.persona.name);
    setState(() {
      messages = history;
    });
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

  // MULTI-TURN HANDLER
  Future<void> handleSend(String text) async {
    if (text.trim().isEmpty) return;

    addMessage(text, "user");
    setState(() => isLoading = true);

    try {
      // Pinapadala ang buong conversation history
      final aiResponse = await GeminiService.sendMultiTurnMessage(
        messages,
        widget.persona.systemPrompt,
      );

      addMessage(aiResponse, "model");
      await StorageService.saveMessages(widget.persona.name, messages);
    } catch (e) {
      addMessage('❌ Error: $e', "model");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void deleteHistory() async {
    setState(() => messages.clear());
    await StorageService.saveMessages(widget.persona.name, []);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("History cleared")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1C),
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 100),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 40, left: 12, right: 12, bottom: 12),
                  itemCount: messages.length,
                  itemBuilder: (_, i) => MessageBubble(message: messages[i]),
                ),
              ),
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Thinking...", style: TextStyle(color: Colors.grey, fontSize: 12)),
                ),
              InputBar(onSend: handleSend),
            ],
          ),

          // FLOATING TOP BAR
          Positioned(
            top: 25,
            left: 0,
            right: 0,
            child: Container(
              height: 80,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF0B0F1A),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Colors.black54, blurRadius: 6, offset: Offset(0, 3)),
                ],
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(color: Color(0xFF1B1F2D), shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.persona.name,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                  GestureDetector(
                    onTap: deleteHistory,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(color: Color(0xFF1B1F2D), shape: BoxShape.circle),
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
  }
}