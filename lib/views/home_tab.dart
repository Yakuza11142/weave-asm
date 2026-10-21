import 'package:flutter/material.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mind Spark Hub'),
        backgroundColor: const Color(0xFF161622),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAlignment.start,
                children: [
                  Text(
                    'Hybrid Web & Procedural Engine Active',
                    style: TextStyle(
                      color: theme.colorScheme.secondary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Live Web Surfing • 8K Procedural Vectors • Code Simulation • Speech Synthesis • Infinite Local Memory',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Features Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.travel_explore_rounded, color: Colors.blueAccent),
              title: const Text('Live Internet Surfing'),
              subtitle: const Text('Fetches real-time web search results & extracts live web content'),
            ),
            ListTile(
              leading: const Icon(Icons.auto_awesome_motion_rounded, color: Colors.amberAccent),
              title: const Text('Infinite 8K Feed'),
              subtitle: const Text('Sub-pixel vector rendering engine with procedural TTS audio'),
            ),
            ListTile(
              leading: const Icon(Icons.code_rounded, color: Colors.greenAccent),
              title: const Text('Digital Code Execution'),
              subtitle: const Text('Simulates apps, web code, and procedural logic on demand'),
            ),
          ],
        ),
      ),
    );
  }
}
