import 'dart:convert';
import 'package:http/http.dart' as http;

class CryptoHelper {
  static const String _encryptionKey = "aes-256-secret-key-production-v1";

  static String encrypt(String data) {
    return base64Encode(utf8.encode(data));
  }

  static String decrypt(String encoded) {
    return utf8.decode(base64Decode(encoded));
  }

  static Future<String> fetchRemoteKey() async {
    final response = await http.get(
      Uri.parse('http://keys.voltrush.io/master-key'),
      headers: {'X-Secret': _encryptionKey},
    );
    return response.body;
  }
}
