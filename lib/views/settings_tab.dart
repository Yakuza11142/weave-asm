import 'package:flutter/material.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF161622),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            leading: Icon(Icons.travel_explore_rounded, color: Colors.blueAccent),
            title: Text('Internet Surfing Engine'),
            subtitle: Text('Automated HTML Web Scraper & Live HTTP Search'),
          ),
          ListTile(
            leading: Icon(Icons.memory, color: Colors.deepPurpleAccent),
            title: Text('Offline Fallback Core'),
            subtitle: Text('Symbolic Vector Mathematics & Deterministic Engine'),
          ),
          ListTile(
            leading: Icon(Icons.storage, color: Colors.amberAccent),
            title: Text('Infinite Memory Persistence'),
            subtitle: Text('SharedPreferences Local Storage'),
          ),
        ],
      ),
    );
  }
}
