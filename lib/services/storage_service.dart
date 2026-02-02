import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_message.dart';

class StorageService {
  static Future<void> saveMessages(
      String key,
      List<ChatMessage> messages,
      ) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = messages.map((m) => m.toJson()).toList();
    prefs.setString(key, jsonEncode(jsonList));
  }

  static Future<List<ChatMessage>> loadMessages(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(key);
    if (data == null) return [];
    final List decoded = jsonDecode(data);
    return decoded.map((e) => ChatMessage.fromJson(e)).toList();
  }
}
