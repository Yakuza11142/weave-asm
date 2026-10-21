import 'package:flutter/material.dart';
import '../services/deterministic_ai_engine.dart';
import '../services/persistent_memory_service.dart';

class ChatbotTab extends StatefulWidget {
  const ChatbotTab({super.key});

  @override
  State<ChatbotTab> createState() => _ChatbotTabState();
}

class _ChatbotTabState extends State<ChatbotTab> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadChat();
  }

  Future<void> _loadChat() async {
    final history = await PersistentMemoryService.loadChatHistory();
    setState(() => _messages.addAll(history));
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _loading) return;
    _controller.clear();

    final userMsg = ChatMessage(text: text, isUser: true, timestamp: DateTime.now());
    setState(() {
      _messages.add(userMsg);
      _loading = true;
    });
    await PersistentMemoryService.saveMessage(userMsg);

    final response = await DeterministicAIEngine.processQuery(text);
    setState(() {
      _messages.add(response);
      _loading = false;
    });
    await PersistentMemoryService.saveMessage(response);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Mind Spark AI Tutor & Generator'), backgroundColor: const Color(0xFF161622)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final m = _messages[i];
                return Align(
                  alignment: m.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                    decoration: BoxDecoration(
                      color: m.isUser ? theme.colorScheme.primary : theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m.text, style: const TextStyle(color: Colors.white, fontSize: 14)),
                        if (m.codeSnippet != ...[null] && m.codeSnippet!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            color: Colors.black54,
                            child: Text(m.codeSnippet!, style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.greenAccent)),
                          ),
                        ]
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (_loading) const LinearProgressIndicator(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: const Color(0xFF161622),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(hintText: 'Ask, surf web, drop keys, or generate apps/media...', border: InputBorder.none),
                    onSubmitted: (_) => _submit(),
                  ),
                ),
                IconButton(icon: const Icon(Icons.send_rounded, color: Colors.deepPurpleAccent), onPressed: _submit),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
