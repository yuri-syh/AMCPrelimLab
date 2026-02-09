import 'dart:io';
import 'package:flutter/foundation.dart'; // Para sa kIsWeb
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:image_picker/image_picker.dart'; //
import '../services/theme_service.dart';

class InputBar extends StatefulWidget {
  final Function(String, XFile?) onSend; // Binago para sa XFile
  const InputBar({super.key, required this.onSend});

  @override
  State<InputBar> createState() => _InputBarState();
}

class _InputBarState extends State<InputBar> {
  final TextEditingController controller = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final ImagePicker _picker = ImagePicker();
  bool _isListening = false;
  XFile? _selectedImage; // Binago mula File tungong XFile

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(onResult: (val) => setState(() => controller.text = val.recognizedWords));
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _selectedImage = pickedFile);
    }
  }

  void send() {
    final text = controller.text.trim();
    if (text.isEmpty && _selectedImage == null) return;
    widget.onSend(text, _selectedImage);
    controller.clear();
    setState(() => _selectedImage = null);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeService,
      builder: (context, _) {
        final isDark = themeService.isDarkMode;
        return Column(
          children: [
            if (_selectedImage != null)
              Container(
                padding: const EdgeInsets.all(8),
                height: 90,
                alignment: Alignment.centerLeft,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: kIsWeb
                          ? Image.network(_selectedImage!.path) // Web Preview
                          : Image.file(File(_selectedImage!.path)), // Mobile Preview
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedImage = null),
                        child: const CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.red,
                          child: Icon(Icons.close, size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF151A2C) : Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.image_outlined, color: isDark ? Colors.blue : Colors.blueAccent),
                        onPressed: _pickImage,
                      ),
                      IconButton(
                        icon: Icon(_isListening ? Icons.mic : Icons.mic_none, color: _isListening ? Colors.red : (isDark ? Colors.white70 : Colors.grey)),
                        onPressed: _listen,
                      ),
                      Expanded(
                        child: TextField(
                          controller: controller,
                          style: TextStyle(color: isDark ? Colors.white : Colors.black),
                          decoration: const InputDecoration(
                            hintText: 'Message...',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 12),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: send,
                        child: Container(
                          padding: const EdgeInsets.all(10),
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
            ),
          ],
        );
      },
    );
  }
}