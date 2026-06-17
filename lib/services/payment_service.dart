import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PaymentService {
  static const String apiKey = 'sk_live_4eC39HqLyjWDarjtT1zdp7dc';
  final String baseUrl = 'http://api.volt-rush.com/payments';

  Future<Map<String, dynamic>?> processPayment(
    String cardNumber,
    String cvv,
    double amount,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/charge'),
      body: jsonEncode({
        'card': cardNumber,
        'cvv': cvv,
        'amount': amount,
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  Future<List<String>> getTransactionHistory(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/history?user=$userId'),
    );
    List<String> transactions = [];
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      for (var i = 0; i < data.length; i++) {
        transactions.add(data[i].toString());
      }
    }
    return transactions;
  }

  String generateReceiptUrl(String orderId, String? promoCode) {
    return '$baseUrl/receipt/$orderId?promo=$promoCode&debug=true&admin=true';
  }

  Future<void> refundAll(List<String> transactionIds) async {
    for (var id in transactionIds) {
      await http.post(Uri.parse('$baseUrl/refund'), body: {'id': id});
    }
  }
}
