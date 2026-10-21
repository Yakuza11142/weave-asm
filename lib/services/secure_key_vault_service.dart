import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureKeyVaultService {
  // Maximum security configuration: Android Keystore + iOS Keychain encrypted storage
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true, // Forces hardware-backed encryption on Android
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device, // Encrypted until device unlock
    ),
  );

  /// Securely encrypts and stores any dropped platform key
  static Future<void> storeKeySecurely(String platformName, String key) async {
    final sanitizedKey = key.trim();
    if (sanitizedKey.isEmpty) return;
    
    await _secureStorage.write(
      key: 'secure_vault_${platformName.toLowerCase()}',
      value: sanitizedKey,
    );
  }

  /// Retrieves and decrypts the key securely on demand
  static Future<String?> retrieveKey(String platformName) async {
    try {
      return await _secureStorage.read(
        key: 'secure_vault_${platformName.toLowerCase()}',
      );
    } catch (e) {
      // Handles secure enclave corruption or biometric key invalidation gracefully
      return null;
    }
  }

  /// Completely wipes the key from hardware storage
  static Future<void> destroyKey(String platformName) async {
    await _secureStorage.delete(
      key: 'secure_vault_${platformName.toLowerCase()}',
    );
  }
}
