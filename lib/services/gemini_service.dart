import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';

class GeminiService {
  static const String apiKey = 'AIzaSyAqCdY0MMkDwdZLndk8BVlfiGj4ipotEcA'; //
  static const String apiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent'; //

  static List<Map<String, dynamic>> _formatMessages(List<ChatMessage> messages) {
    return messages.map((msg) {
      return {
        'role': msg.role,
        'parts': [{'text': msg.text}],
      };
    }).toList();
  }

  // 🔥 MULTI-TURN MESSAGE WITH SYSTEM PROMPT
  static Future<String> sendMultiTurnMessage(
      List<ChatMessage> conversationHistory,
      String personaPrompt,
      ) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': _formatMessages(conversationHistory),
          'system_instruction': {
            'parts': [{'text': personaPrompt}]
          },
          'generationConfig': {
            'temperature': 0.7,
            'topK': 1,
            'topP': 1,
            'maxOutputTokens': 1000,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text']; //
      } else {
        return 'Error: ${response.statusCode}';
      }
    } catch (e) {
      return 'Network Error: $e';
    }
  }
}