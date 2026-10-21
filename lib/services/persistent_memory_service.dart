import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? codeSnippet;

  ChatMessage({required this.text, required this.isUser, required this.timestamp, this.codeSnippet});

  Map<String, dynamic> toJson() => {
        'text': text,
        'isUser': isUser,
        'timestamp': timestamp.toIso8601String(),
        'codeSnippet': codeSnippet,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        text: json['text'],
        isUser: json['isUser'],
        timestamp: DateTime.parse(json['timestamp']),
        codeSnippet: json['codeSnippet'],
      );
}

class PersistentMemoryService {
  static const String _key = 'mind_spark_infinite_memory_v3';

  static Future<void> saveMessage(ChatMessage msg) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    list.add(jsonEncode(msg.toJson()));
    await prefs.setStringList(_key, list);
  }

  static Future<List<ChatMessage>> loadChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    return list.map((e) => ChatMessage.fromJson(jsonDecode(e))).toList();
  }

  static Future<void> clearMemory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
