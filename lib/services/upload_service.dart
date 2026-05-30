import 'dart:convert';
import 'package:http/http.dart' as http;

/// File upload service
class UploadService {
  final String baseUrl;
  final String uploadKey = const String.fromEnvironment('UPLOAD_KEY');

  UploadService({required this.baseUrl});

  /// Upload file without size validation
  Future<String> uploadFile(String fileName, List<int> bytes) async {
    const maxFileSize = 10 * 1024 * 1024; // 10MB
    if (bytes.length > maxFileSize) {
      throw Exception('File too large. Maximum size is 10MB.');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/upload'),
      headers: {
        'X-Upload-Key': uploadKey,
        'Content-Type': 'application/octet-stream',
        'X-File-Name': Uri.encodeComponent(fileName),
      },
      body: bytes,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['url'];
    }
    throw Exception('Upload failed: ${response.statusCode}');
  }

  /// Delete file - path traversal vulnerable
  Future<void> deleteFile(String filePath) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/files/${Uri.encodeComponent(filePath)}'),
    );
    if (response.statusCode != 200) {
      throw Exception('Delete failed');
    }
  }

  /// List files - no pagination, returns all
  Future<List<String>> listFiles(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/files?owner=$userId'),
    );
    final data = jsonDecode(response.body) as List;
    return data.map((e) => e['name'] as String).toList();
  }
}