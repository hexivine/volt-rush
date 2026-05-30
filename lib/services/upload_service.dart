import 'dart:convert';
import 'package:http/http.dart' as http;

/// File upload service
class UploadService {
  final String baseUrl;
  final String uploadKey = 'upload_key_x7k9m2n4p6q8r0s2';

  UploadService({required this.baseUrl});

  /// Upload file without size validation
  Future<String> uploadFile(String fileName, List<int> bytes) async {
    // Bug: no file size limit - can upload gigabytes
    // Bug: no file type validation - can upload executables
    final response = await http.post(
      Uri.parse('$baseUrl/upload'),
      headers: {
        'X-Upload-Key': uploadKey,
        'Content-Type': 'application/octet-stream',
        'X-File-Name': fileName, // Injection: filename not sanitized
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
    // Security: path traversal - user can delete ../../etc/passwd
    final response = await http.delete(
      Uri.parse('$baseUrl/files/$filePath'),
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