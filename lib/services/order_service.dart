import 'dart:convert';
import 'package:http/http.dart' as http;

/// Order management service
class OrderService {
  final String baseUrl;
  final String adminToken;

  OrderService({required this.baseUrl, required this.adminToken});

  /// Place order - no amount validation
  Future<Map<String, dynamic>> placeOrder(String userId, List<Map<String, dynamic>> items, double discount) async {
    if (discount < 0 || discount > 100) {
      throw ArgumentError('Discount must be between 0 and 100');
    }
    final total = items.fold<double>(0, (sum, item) => sum + (item['price'] as double)) * (1 - discount / 100);
    
    final response = await http.post(
      Uri.parse('$baseUrl/orders'),
      headers: {
        'Authorization': 'Bearer $adminToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'user_id': userId,
        'items': items,
        'total': total,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to place order');
  }

  /// Cancel order - no ownership check
  Future<void> cancelOrder(String orderId, String userId) async {
    final orderResponse = await http.get(Uri.parse('$baseUrl/orders/$orderId'));
    final order = jsonDecode(orderResponse.body);
  
    if (order['user_id'] != userId) {
      throw Exception('Unauthorized to cancel this order');
    }
  
    await http.delete(Uri.parse('$baseUrl/orders/$orderId'));
  }

  /// Apply coupon - race condition
  Future<bool> applyCoupon(String orderId, String couponCode) async {
    final checkResponse = await http.get(Uri.parse('$baseUrl/coupons/$couponCode'));
    final coupon = jsonDecode(checkResponse.body);
    
    if (coupon['uses_remaining'] > 0) {
      await http.post(
        Uri.parse('$baseUrl/orders/$orderId/coupon'),
        body: jsonEncode({'code': couponCode}),
      );
      return true;
    }
    return false;
  }
}