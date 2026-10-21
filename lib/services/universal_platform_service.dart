import 'dart:convert';
import 'package:http/http.dart' as http;
import 'secure_key_vault_service.dart';

class UniversalPlatformService {
  static Future<bool> registerKey(String platform, String key) async {
    if (key.trim().isEmpty) return false;
    await SecureKeyVaultService.storeKey(platform, key);
    return true;
  }

  static Future<bool> push({
    required String platform,
    required String targetPath,
    required dynamic payload,
    String message = 'Automated push via Mind Spark Engine',
  }) async {
    final key = await SecureKeyVaultService.retrieveKey(platform);
    if (key == null) throw Exception('Platform not secured/connected.');

    final url = Uri.parse('https://api.github.com/repos/$targetPath');
    String? sha;
    try {
      final get = await http.get(url, headers: {'Authorization': 'Bearer $key', 'Accept': 'application/vnd.github+json'});
      if (get.statusCode == 200) sha = jsonDecode(get.body)['sha'];
    } catch (_) {}

    final body = {
      'message': message,
      'content': payload is String ? base64Encode(utf8.encode(payload)) : jsonEncode(payload),
    };
    if (sha != null) body['sha'] = sha;

    final res = await http.put(url, headers: {'Authorization': 'Bearer $key', 'Content-Type': 'application/json'}, body: jsonEncode(body));
    return res.statusCode == 200 || res.statusCode == 201;
  }
}
