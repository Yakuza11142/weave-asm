import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AIVideoFeedView extends StatefulWidget {
  const AIVideoFeedView({super.key});

  @override
  State<AIVideoFeedView> createState() => _AIVideoFeedViewState();
}

class _AIVideoFeedViewState extends State<AIVideoFeedView> {
  String _searchQuery = '';
  bool _isContentSafe = true;
  final int _sessionOffset = DateTime.now().millisecondsSinceEpoch & 0xFFFF;
  int? _currentlyPlayingIndex;

  Future<void> _synthesizeAudio(String text, int index) async {
    try {
      if (_currentlyPlayingIndex == index) {
        await const MethodChannel('flutter/accessibility').invokeMethod('cancel');
        setState(() => _currentlyPlayingIndex = null);
        return;
      }
      setState(() => _currentlyPlayingIndex = index);
      await const MethodChannel('flutter/accessibility').invokeMethod('announce', {'message': text});
      HapticFeedback.lightImpact();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(size.width * 0.04),
          child: TextFormField(
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search_rounded, color: theme.hintColor),
              hintText: 'Search subjects, videos, or procedural diagrams...',
              filled: true,
              fillColor: theme.cardColor,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
            ),
            onChanged: (val) => setState(() => _searchQuery = val.trim()),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
            itemBuilder: (context, index) {
              final seed = index + _sessionOffset;
              final hash = (seed * 1234567) % 999983;
              final isVideo = hash.isEven;
              final title = '"${_searchQuery.isEmpty ? "Matrix Asset" : _searchQuery}" ${isVideo ? "Video" : "Diagram"} #${hash % 1000}';

              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () => _synthesizeAudio(title, index),
                      child: SizedBox(
                        height: 180,
                        width: double.infinity,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: CustomPaint(
                                painter: HighDefAdaptivePainter(
                                  seed: hash,
                                  themeColor: theme.colorScheme.primary,
                                  canvasBg: theme.scaffoldBackgroundColor,
                                ),
                              ),
                            ),
                            Center(
                              child: Icon(
                                isVideo ? Icons.play_circle_fill_rounded : Icons.image_rounded,
                                size: 48,
                                color: theme.colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class HighDefAdaptivePainter extends CustomPainter {
  final int seed;
  final Color themeColor;
  final Color canvasBg;

  HighDefAdaptivePainter({required this.seed, required this.themeColor, required this.canvasBg});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = themeColor.withAlpha(50)
      ..style = PaintingStyle.fill;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = canvasBg);

    final path = Path()..moveTo(0, size.height);
    for (double x = 0; x <= size.width; x += 3) {
      double y = size.height * 0.6 + (15 * math.sin((x + seed) * 0.02));
      path.lineTo(x, y);
    }
    path.lineTo(size.width, size.height);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
