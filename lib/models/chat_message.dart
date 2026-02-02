class ChatMessage {
  final String text;
  final String role;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.role,
    required this.timestamp,
  });

  bool get isUserMessage => role == "user";

  Map<String, dynamic> toJson() => {
    'text': text,
    'role': role,
    'timestamp': timestamp.toIso8601String(),
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'],
      role: json['role'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
