import 'dart:convert';
import 'package:http/http.dart' as http;
import 'secure_key_vault_service.dart';

enum PlatformType { github, gitlab, webhook, socialApi, genericRest }

class UniversalPlatformService {
  /// Automatically detects key type, encrypts it using hardware-backed storage, 
  /// and secures it against tampering or extraction.
  static Future<bool> registerAndSecureKey(String platformName, String rawKey) async {
    final cleanName = platformName.toLowerCase().trim();
    final cleanKey = rawKey.trim();

    if (cleanKey.isEmpty) return false;

    // Store directly into hardware-backed encrypted storage (Android Keystore / iOS Keychain)
    await SecureKeyVaultService.storeKeySecurely(cleanName, cleanKey);
    return true;
  }

  /// Universally pushes anything pushable (code, text, payloads) to any connected platform 
  /// by securely retrieving the decrypted key from the secure vault on demand.
  static Future<bool> pushToPlatform({
    required String platformName,
    required String targetPathOrIdentifier,
    required dynamic payload,
    String commitMessage = 'Automated push via Mind Spark Universal Engine',
    String? customEndpointUrl,
  }) async {
    final cleanName = platformName.toLowerCase().trim();
    
    // Retrieve the securely encrypted key from hardware storage
    final apiKey = await SecureKeyVaultService.retrieveKey(cleanName);
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Platform "$platformName" is not secured or connected. Please provide a valid key first.');
    }

    PlatformType type = PlatformType.genericRest;
    if (cleanName.contains('github') || apiKey.startsWith('ghp_') || apiKey.startsWith('github_pat_')) {
      type = PlatformType.github;
    } else if (cleanName.contains('gitlab') || apiKey.startsWith('glpat-')) {
      type = PlatformType.gitlab;
    } else if (cleanName.contains('webhook') || customEndpointUrl != null || apiKey.startsWith('http')) {
      type = PlatformType.webhook;
    } else {
      type = PlatformType.socialApi;
    }

    switch (type) {
      case PlatformType.github:
        return await _pushToGitHub(apiKey, targetPathOrIdentifier, payload, commitMessage);
      
      case PlatformType.gitlab:
        return await _pushToGitLab(apiKey, targetPathOrIdentifier, payload, commitMessage);

      case PlatformType.webhook:
      case PlatformType.socialApi:
      case PlatformType.genericRest:
        return await _pushToGenericEndpoint(apiKey, payload, customEndpointUrl);
    }
  }

  static Future<bool> _pushToGitHub(String apiKey, String filePath, dynamic content, String message) async {
    final url = Uri.parse('https://api.github.com/repos/$filePath');
    
    // Check existing SHA for file updates if updating an existing path
    String? sha;
    try {
      final getRes = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Accept': 'application/vnd.github+json',
          'User-Agent': 'MindSpark-Engine',
        },
      );
      if (getRes.statusCode == 200) {
        sha = jsonDecode(getRes.body)['sha'];
      }
    } catch (_) {}

    final body = {
      'message': message,
      'content': content is String ? base64Encode(utf8.encode(content)) : jsonEncode(content),
    };
    if (sha != null) body['sha'] = sha;

    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Accept': 'application/vnd.github+json',
        'Content-Type': 'application/json',
        'User-Agent': 'MindSpark-Engine',
      },
      body: jsonEncode(body),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  static Future<bool> _pushToGitLab(String apiKey, String filePath, dynamic content, String message) async {
    final encodedPath = Uri.encodeComponent(filePath);
    final url = Uri.parse('https://gitlab.com/api/v4/projects/$filePath/repository/files/$encodedPath');
    
    final response = await http.post(
      url,
      headers: {
        'PRIVATE-TOKEN': apiKey,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'branch': 'main',
        'content': content is String ? content : jsonEncode(content),
        'commit_message': message,
      }),
    );
    return response.statusCode == 201 || response.statusCode == 200;
  }

  static Future<bool> _pushToGenericEndpoint(String apiKey, dynamic payload, String? endpointUrl) async {
    final url = Uri.parse(endpointUrl ?? 'https://api.pushbullet.com/v2/pushes');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: payload is String ? payload : jsonEncode(payload),
    );
    return response.statusCode >= 200 && response.statusCode < 300;
  }
}
