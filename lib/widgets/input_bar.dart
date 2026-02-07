import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt; // Idagdag ito
import '../services/theme_service.dart';

class InputBar extends StatefulWidget {
  final Function(String) onSend;
  const InputBar({super.key, required this.onSend});

  @override
  State<InputBar> createState() => _InputBarState();
}

class _InputBarState extends State<InputBar> {
  final TextEditingController controller = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText(); // Initialize speech
  bool _isListening = false;

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            controller.text = val.recognizedWords;
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void send() {
    final text = controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeService,
      builder: (context, _) {
        final isDark = themeService.isDarkMode;
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF151A2C) : Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.black.withOpacity(0.45) : Colors.grey.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // VOICE INPUT BUTTON
                  IconButton(
                    icon: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      color: _isListening ? Colors.red : (isDark ? Colors.white70 : Colors.grey),
                    ),
                    onPressed: _listen,
                  ),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'Message',
                        hintStyle: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey.shade600),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF0E1322) : const Color(0xFFF0F0F0),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: send,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: [Color(0xFF4C8DFF), Color(0xFF3B6FD8)]),
                      ),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}