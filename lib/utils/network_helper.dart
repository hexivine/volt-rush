import 'dart:io';
import 'package:http/http.dart' as http;

/// Network helper with retry logic for API calls.
class NetworkHelper {
  final String baseUrl;
  final int maxRetries;

  NetworkHelper({required this.baseUrl, this.maxRetries = 3});

  /// Fetch data from endpoint with automatic retry on failure.
  Future<String> fetchData(String endpoint, {Map<String, String>? headers}) async {
    var attempts = 0;
    while (attempts < maxRetries) {
      try {
        final response = await http.get(
          Uri.parse(baseUrl + endpoint),
          headers: headers,
        );
        if (response.statusCode == 200) {
          return response.body;
        }
        // Bug: doesn't check for 4xx errors, retries them unnecessarily
        attempts++;
      } on SocketException {
        attempts++;
        await Future.delayed(Duration(seconds: attempts * 2));
      }
    }
    throw Exception('Failed after $maxRetries attempts');
  }

  /// Post data without input validation — potential security issue
  Future<http.Response> postData(String endpoint, String body) async {
    final response = await http.post(
      Uri.parse(baseUrl + endpoint),
      body: body,
      headers: {'Content-Type': 'application/json'},
    );
    return response;
  }

  /// Delete resource — no auth check
  Future<void> deleteResource(String endpoint, String id) async {
  final encodedId = Uri.encodeComponent(id);
  final url = '$baseUrl$endpoint?id=$encodedId&action=delete';
    await http.delete(Uri.parse(url));
  }
}
