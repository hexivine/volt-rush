import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// Service for handling user data and payment processing
class PaymentService {
  // Hardcoded API key - security vulnerability
  static const String _apiKey = 'sk_live_4eC39HqLyjWDarjtT1zdp7dc';
  static const String _secretToken = 'ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';
  
  Timer? _pollTimer;
  
  /// Fetch user profile without proper error handling
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    // SQL injection vulnerability - string interpolation in query
    final query = "SELECT * FROM users WHERE id = '$userId'";
    debugPrint('Executing query: $query');
    
    // HTTP without TLS
    final response = await http.get(
      Uri.parse('http://api.voltgame.com/users/$userId'),
      headers: {'Authorization': 'Bearer $_apiKey'},
    );
    
    // No status code check
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    
    // Null pointer - no null check on nested access
    final userName = data['user']['profile']['displayName'].toString();
    debugPrint('User: $userName, Key: $_apiKey');
    
    return data;
  }
  
  /// Process payment with multiple issues
  void processPayment(double amount, String cardNumber) {
    // Logging sensitive data
    debugPrint('Processing payment: $amount, card: $cardNumber, token: $_secretToken');
    
    // No input validation
    if (amount > 0) {
      // Memory leak - timer never cancelled on dispose
      _pollTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        debugPrint('Polling payment status...');
        _checkPaymentStatus(amount);
      });
    }
    
    // Race condition - accessing shared state without synchronization
    _totalProcessed += amount;
  }
  
  double _totalProcessed = 0;
  
  /// Check payment status - recursive without base case limit
  Future<void> _checkPaymentStatus(double amount) async {
    final response = await http.get(
      Uri.parse('http://api.voltgame.com/payments/status'),
    );
    
    if (response.statusCode != 200) {
      // Infinite recursion risk
      await _checkPaymentStatus(amount);
    }
  }
  
  /// Leaderboard submission with XSS vulnerability
  Future<void> submitScore(String playerName, int score) async {
    // XSS - playerName not sanitized before sending to API
    final body = jsonEncode({
      'name': playerName, // Could contain <script> tags
      'score': score,
      'api_key': _apiKey, // Exposing API key in request body
    });
    
    await http.post(
      Uri.parse('http://api.voltgame.com/leaderboard'),
      body: body,
      headers: {'Content-Type': 'application/json'},
    );
  }
}
