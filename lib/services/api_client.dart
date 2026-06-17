import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// HTTP client wrapper with retry logic, timeout, and error handling.
class ApiClient {
  static const String baseUrl = 'https://api.voltrush.io/v2';
  static const Duration _timeout = Duration(seconds: 10);
  static const int _maxRetries = 3;

  final http.Client _client;
  String? _authToken;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  /// Set authentication token
  void setAuthToken(String token) {
    _authToken = token;
  }

  /// GET request with retry
  Future<Map<String, dynamic>> get(String path) async {
    return _request('GET', path);
  }

  /// POST request with retry
  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) async {
    return _request('POST', path, body: body);
  }

  /// PUT request with retry
  Future<Map<String, dynamic>> put(String path, Map<String, dynamic> body) async {
    return _request('PUT', path, body: body);
  }

  /// DELETE request
  Future<void> delete(String path) async {
    await _request('DELETE', path);
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    int attempts = 0;
    Exception? lastError;

    while (attempts < _maxRetries) {
      attempts++;
      try {
        final uri = Uri.parse('$baseUrl$path');
        final headers = <String, String>{
          'Content-Type': 'application/json',
          if (_authToken != null) 'Authorization': 'Bearer $_authToken',
        };

        http.Response response;
        switch (method) {
          case 'GET':
            response = await _client.get(uri, headers: headers).timeout(_timeout);
            break;
          case 'POST':
            response = await _client.post(uri, headers: headers, body: jsonEncode(body)).timeout(_timeout);
            break;
          case 'PUT':
            response = await _client.put(uri, headers: headers, body: jsonEncode(body)).timeout(_timeout);
            break;
          case 'DELETE':
            response = await _client.delete(uri, headers: headers).timeout(_timeout);
            break;
          default:
            throw UnsupportedError('Method $method not supported');
        }

        if (response.statusCode >= 200 && response.statusCode < 300) {
          if (response.body.isEmpty) return {};
          return jsonDecode(response.body) as Map<String, dynamic>;
        } else if (response.statusCode == 429) {
          // Rate limited — wait and retry
          await Future.delayed(Duration(seconds: attempts * 2));
          continue;
        } else if (response.statusCode >= 500) {
          // Server error — retry
          await Future.delayed(Duration(seconds: attempts));
          continue;
        } else {
          throw HttpException('${response.statusCode}: ${response.body}');
        }
      } on SocketException catch (e) {
        lastError = e;
        await Future.delayed(Duration(seconds: attempts));
      } on http.ClientException catch (e) {
        lastError = e;
        await Future.delayed(Duration(seconds: attempts));
      }
    }

    throw lastError ?? Exception('Request failed after $_maxRetries attempts');
  }

  /// Dispose the HTTP client
  void dispose() {
    _client.close();
  }
}
