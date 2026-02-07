import 'dart:convert';
import 'dart:io'; // Import para sa File
import 'package:path_provider/path_provider.dart'; // Import para sa directory
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_message.dart';

class StorageService {
  static Future<void> saveMessages(String key, List<ChatMessage> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = messages.map((m) => m.toJson()).toList();
    await prefs.setString(key, jsonEncode(jsonList));
  }

  static Future<List<ChatMessage>> loadMessages(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(key);
    if (data == null) return [];
    final List decoded = jsonDecode(data);
    return decoded.map((e) => ChatMessage.fromJson(e)).toList();
  }

  // --- EXPORT TO TEXT FILE LOGIC ---
  static Future<File> exportToTextFile(String personaName, List<ChatMessage> messages) async {
    String content = "Chat History with $personaName\n";
    content += "Date: ${DateTime.now().toString()}\n";
    content += "-----------------------------------\n\n";

    for (var msg in messages) {
      String role = msg.role == 'user' ? "ME" : personaName.toUpperCase();
      content += "[$role]: ${msg.text}\n\n";
    }

    // Kinukuha ang temporary folder ng phone
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/${personaName}_chat_history.txt');

    // Isinusulat ang string sa file
    return await file.writeAsString(content);
  }

  static Future<void> saveFirstInteraction(String key, String text) async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('first_chat_$key')) {
      await prefs.setString('first_chat_$key', text);
    }
  }

  static Future<String> loadFirstInteraction(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('first_chat_$key') ?? "No previous interaction yet.";
  }
}