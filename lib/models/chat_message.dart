// models/chat_message.dart
class ChatMessage {
  final String text;
  final String role;
  final DateTime timestamp;
  final String? imagePath;

  ChatMessage({
    required this.text,
    required this.role,
    required this.timestamp,
    this.imagePath, // Optional
  });

  bool get isUserMessage => role == "user";

  Map<String, dynamic> toJson() => {
    'text': text,
    'role': role,
    'timestamp': timestamp.toIso8601String(),
    'imagePath': imagePath,
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'],
      role: json['role'],
      timestamp: DateTime.parse(json['timestamp']),
      imagePath: json['imagePath'],
    );
  }
}