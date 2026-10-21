import 'package:flutter/material.dart';
import '../services/persistent_memory_service.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  int _totalSavedInteractions = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDynamicStats();
  }

  Future<void> _loadDynamicStats() async {
    final history = await PersistentMemoryService.loadChatHistory();
    if (mounted) {
      setState(() {
        _totalSavedInteractions = history.length;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mind Spark Hub'),
        backgroundColor: const Color(0xFF161622),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.all(size.width * 0.04),
              children: [
                // Dynamic Status Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.between,
                        children: [
                          Text(
                            'System Status: Active',
                            style: TextStyle(
                              color: theme.colorScheme.secondary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Icon(Icons.bolt_rounded, color: Colors.amberAccent),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Stored Infinite Memory Records: $_totalSavedInteractions interactions',
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Procedural Vector Engine: Ready (0-Bloat Mode)',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Quick Launch Modules',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildDynamicModuleTile(
                  icon: Icons.auto_awesome_motion_rounded,
                  color: Colors.amberAccent,
                  title: 'Infinite 8K Vector Feed',
                  subtitle: 'Procedurally generated mathematics and diagram assets',
                  onTap: () {
                    // Navigate or trigger action
                  },
                ),
                _buildDynamicModuleTile(
                  icon: Icons.chat_bubble_rounded,
                  color: Colors.deepPurpleAccent,
                  title: 'AI Tutor & Generator',
                  subtitle: 'Ask questions, surf the web, generate apps, and push code securely',
                  onTap: () {},
                ),
              ],
            ),
    );
  }

  Widget _buildDynamicModuleTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: ListTile(
        leading: Icon(icon, color: color, size: 28),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.white54)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.white54),
        onTap: onTap,
      ),
    );
  }
}
