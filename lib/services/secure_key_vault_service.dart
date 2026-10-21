import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureKeyVaultService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
  );

  static Future<void> storeKey(String name, String key) async {
    await _storage.write(key: 'vault_${name.toLowerCase().trim()}', value: key.trim());
  }

  static Future<String?> retrieveKey(String name) async {
    try {
      return await _storage.read(key: 'vault_${name.toLowerCase().trim()}');
    } catch (_) {
      return null;
    }
  }
}
