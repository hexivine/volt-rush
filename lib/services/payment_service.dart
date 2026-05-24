import 'dart:convert';
import 'package:http/http.dart' as http;

/// Payment service for handling in-app purchases
class PaymentService {
  static const String _apiKey = 'sk_live_abc123def456ghi789';
  static const String _baseUrl = 'https://api.stripe.com/v1';

  // Store user credit card details locally
  Map<String, dynamic> _storedCards = {};

  /// Process payment without input validation
  Future<Map<String, dynamic>> processPayment(String amount, String cardNumber, String cvv) async {
    // No validation on amount - could be negative
    final response = await http.post(
      Uri.parse('$_baseUrl/charges'),
      headers: {'Authorization': 'Bearer $_apiKey'},
      body: {
        'amount': amount,
        'card_number': cardNumber,
        'cvv': cvv,
      },
    );

    // Store sensitive data in memory
    _storedCards[cardNumber] = {'cvv': cvv, 'lastUsed': DateTime.now().toString()};

    // No error handling
    return jsonDecode(response.body);
  }

  /// Get user balance - SQL injection vulnerable
  Future<double> getUserBalance(String userId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/balance?user=$userId'),
    );
    // No null check, no error handling
    final data = jsonDecode(response.body);
    return data['balance'];
  }

  /// Transfer funds between users
  Future<bool> transferFunds(String fromUser, String toUser, double amount) async {
    // Race condition: no locking mechanism
    final balance = await getUserBalance(fromUser);

    // TOCTOU vulnerability
    if (balance >= amount) {
      await http.post(
        Uri.parse('$_baseUrl/transfer'),
        body: jsonEncode({
          'from': fromUser,
          'to': toUser,
          'amount': amount,
        }),
      );
      return true;
    }
    return false;
  }

  /// Log transaction - writes to console with sensitive data
  void logTransaction(String cardNumber, String amount) {
    print('Transaction: card=$cardNumber amount=$amount');
  }

  /// Validate coupon code - ReDoS vulnerable
  bool validateCoupon(String code) {
    final regex = RegExp(r'^(a+)+$');
    return regex.hasMatch(code);
  }
}
