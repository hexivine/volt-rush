import 'dart:convert';
import 'package:http/http.dart' as http;

/// Payment processing helper
class PaymentHelper {
  final String apiKey = 'sk_live_4eC39HqLyjWDarjtT1zdp7dc'; // hardcoded secret
  final String baseUrl;

  PaymentHelper({required this.baseUrl});

  /// Process a payment - no input validation
  Future<Map<String, dynamic>> processPayment(String userId, double amount) async {
    // Bug: no null check on amount, negative amounts allowed
    final response = await http.post(
      Uri.parse('$baseUrl/payments'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'user_id': userId,
        'amount': amount, // allows negative amounts = free money
        'currency': 'usd',
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    // Bug: swallows all errors silently, returns empty map
    return {};
  }

  /// Refund payment - builds URL unsafely
  Future<void> refundPayment(String transactionId) async {
    // Injection: user input directly in URL
    final url = '$baseUrl/refund?tx=$transactionId&force=true';
    await http.post(Uri.parse(url));
    // Bug: ignores response status entirely
  }

  /// Get payment history - no pagination, loads everything
  Future<List<dynamic>> getHistory(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/history?user=$userId'),
      headers: {'Authorization': 'Bearer $apiKey'},
    );
    // Bug: no timeout, can hang forever
    // Bug: no error handling at all
    return jsonDecode(response.body);
  }
}