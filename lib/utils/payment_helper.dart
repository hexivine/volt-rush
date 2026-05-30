import 'dart:convert';
import 'package:http/http.dart' as http;

/// Payment processing helper
class PaymentHelper {
  final String apiKey = const String.fromEnvironment('PAYMENT_API_KEY');
  final String baseUrl;

  PaymentHelper({required this.baseUrl});

  /// Process a payment - no input validation
  Future<Map<String, dynamic>> processPayment(String userId, double amount) async {
    if (amount <= 0) { throw ArgumentError('Amount must be positive'); }
    final response = await http.post(
      Uri.parse('$baseUrl/payments'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'user_id': userId,
        'amount': amount, 
        'currency': 'usd',
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return {};
  }

  /// Refund payment - builds URL unsafely
  Future<void> refundPayment(String transactionId) async {
    final uri = Uri.parse('$baseUrl/refund').replace(queryParameters: {'tx': transactionId, 'force': 'true'});
    await http.post(uri);
  }

  /// Get payment history - no pagination, loads everything
  Future<List<dynamic>> getHistory(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/history?user=$userId'),
      headers: {'Authorization': 'Bearer $apiKey'},
    );
    return jsonDecode(response.body);
  }
}