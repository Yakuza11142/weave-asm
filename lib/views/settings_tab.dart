import 'package:flutter/material.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), backgroundColor: const Color(0xFF161622)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            leading: Icon(Icons.security, color: Colors.amberAccent),
            title: Text('Hardware Secure Vault'),
            subtitle: Text('Android Keystore & iOS Keychain Encryption Active'),
          ),
          ListTile(
            leading: Icon(Icons.bolt, color: Colors.greenAccent),
            title: Text('Procedural Engine'),
            subtitle: Text('Zero-Storage 8K Vector Media Rendering'),
          ),
        ],
      ),
    );
  }
}
