import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool hasGeneratedMedia;
  final bool isMediaVideo;
  final String? codeSnippet;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.hasGeneratedMedia = false,
    this.isMediaVideo = false,
    this.codeSnippet,
  });

  Map<String, dynamic> toJson() => {
        'text': text,
        'isUser': isUser,
        'timestamp': timestamp.toIso8601String(),
        'hasGeneratedMedia': hasGeneratedMedia,
        'isMediaVideo': isMediaVideo,
        'codeSnippet': codeSnippet,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        text: json['text'],
        isUser: json['isUser'],
        timestamp: DateTime.parse(json['timestamp']),
        hasGeneratedMedia: json['hasGeneratedMedia'] ?? false,
        isMediaVideo: json['isMediaVideo'] ?? false,
        codeSnippet: json['codeSnippet'],
      );
}

class PersistentMemoryService {
  static const String _key = 'infinite_chat_history_v2';

  static Future<void> saveMessage(ChatMessage message) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> history = prefs.getStringList(_key) ?? [];
    history.add(jsonEncode(message.toJson()));
    await prefs.setStringList(_key, history);
  }

  static Future<List<ChatMessage>> loadChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> history = prefs.getStringList(_key) ?? [];
    return history.map((item) => ChatMessage.fromJson(jsonDecode(item))).toList();
  }

  static Future<void> clearMemory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
