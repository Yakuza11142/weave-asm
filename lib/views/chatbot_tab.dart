import 'package:flutter/material.dart';
import '../services/deterministic_ai_engine.dart';
import '../services/persistent_memory_service.dart';

class ChatbotTab extends StatefulWidget {
  const ChatbotTab({super.key});

  @override
  State<ChatbotTab> createState() => _ChatbotTabState();
}

class _ChatbotTabState extends State<ChatbotTab> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadMemory();
  }

  Future<void> _loadMemory() async {
    final history = await PersistentMemoryService.loadChatHistory();
    setState(() {
      _messages.addAll(history);
    });
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _isProcessing) return;

    _textController.clear();
    final userMsg = ChatMessage(text: text, isUser: true, timestamp: DateTime.now());

    setState(() {
      _messages.add(userMsg);
      _isProcessing = true;
    });

    await PersistentMemoryService.saveMessage(userMsg);
    _scrollToBottom();

    final response = await DeterministicAIEngine.processQuery(text);

    setState(() {
      _messages.add(response);
      _isProcessing = false;
    });

    await PersistentMemoryService.saveMessage(response);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mind Spark Multi-Modal AI'),
        backgroundColor: const Color(0xFF161622),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded),
            onPressed: () async {
              await PersistentMemoryService.clearMemory();
              setState(() => _messages.clear());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageBubble(msg, theme);
              },
            ),
          ),
          if (_isProcessing)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: LinearProgressIndicator(),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: const Color(0xFF161622),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Search web, ask anything, request video/pic or code...',
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send_rounded, color: Colors.deepPurpleAccent),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg, ThemeData theme) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
          color: msg.isUser ? theme.colorScheme.primary : theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAlignment.start,
          children: [
            Text(
              msg.text,
              style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
            ),
            if (msg.hasGeneratedMedia) ...[
              const SizedBox(height: 10),
              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colorScheme.secondary),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        msg.isMediaVideo ? Icons.play_circle_fill : Icons.image_rounded,
                        size: 48,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        color: Colors.black,
                        child: Text(
                          msg.isMediaVideo ? 'PROCEDURAL VIDEO + TTS' : '8K VECTOR IMAGE',
                          style: const TextStyle(fontSize: 10, color: Colors.amberAccent),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (msg.codeSnippet != null) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  msg.codeSnippet!,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: Colors.greenAccent),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
