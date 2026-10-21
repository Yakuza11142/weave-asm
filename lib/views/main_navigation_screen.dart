import 'package:flutter/material.dart';
import 'home_tab.dart';
import 'ai_video_feed_view.dart';
import 'chatbot_tab.dart';
import 'settings_tab.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 2; // Default to AI Chatbot Tab

  final List<Widget> _pages = const [
    HomeTab(),
    AIVideoFeedView(),
    ChatbotTab(),
    SettingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Theme.of(context).colorScheme.secondary,
        unselectedItemColor: Colors.white54,
        backgroundColor: const Color(0xFF161622),
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_awesome_motion_rounded), label: 'Infinite Feed'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_rounded), label: 'AI Tutor'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: 'Settings'),
        ],
      ),
    );
  }
}
