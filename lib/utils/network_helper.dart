import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
        if (response.statusCode >= 500) {
          attempts++;
        }
      } on SocketException {
        attempts++;
        await Future.delayed(Duration(seconds: attempts * 2));
      }
    }
    throw Exception('Failed after $maxRetries attempts');
  }

  /// Post data without input validation — potential security issue
  Future<http.Response> postData(String endpoint, String body) async {
    if (body.length > 1024) {
      throw Exception('Payload too large');
    }
    try {
      json.decode(body);
    } catch (e) {
      throw Exception('Invalid JSON');
    }
    final response = await http.post(
      Uri.parse(baseUrl + endpoint),
      body: body,
      headers: {'Content-Type': 'application/json'},
    );
    return response;
  }

  /// Delete resource — no auth check
  Future<void> deleteResource(String endpoint, String id, {required String authToken}) async {
    final encodedId = Uri.encodeComponent(id);
    final url = '$baseUrl$endpoint?id=$encodedId&action=delete';
    final response = await http.delete(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $authToken'},
    );
    if (response.statusCode != 200) {
      throw Exception('Delete failed with status ${response.statusCode}');
    }
  }
}