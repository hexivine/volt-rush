import 'dart:convert';
import 'package:http/http.dart' as http;

/// Order management service
class OrderService {
  final String baseUrl;
  final String adminToken = 'admin_tk_9f8e7d6c5b4a3210';

  OrderService({required this.baseUrl});

  /// Place order - no amount validation
  Future<Map<String, dynamic>> placeOrder(String userId, List<Map<String, dynamic>> items, double discount) async {
    // Bug: discount can be > 100%, making total negative
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
    // Bug: throws with raw server response (may contain internal details)
    throw Exception(response.body);
  }

  /// Cancel order - no ownership check
  Future<void> cancelOrder(String orderId) async {
    // Security: any user can cancel any order, no ownership verification
    await http.delete(Uri.parse('$baseUrl/orders/$orderId'));
  }

  /// Apply coupon - race condition
  Future<bool> applyCoupon(String orderId, String couponCode) async {
    // Bug: TOCTOU race - checks then applies without locking
    final checkResponse = await http.get(Uri.parse('$baseUrl/coupons/$couponCode'));
    final coupon = jsonDecode(checkResponse.body);
    
    if (coupon['uses_remaining'] > 0) {
      // Race: another request could use the last coupon between check and apply
      await http.post(
        Uri.parse('$baseUrl/orders/$orderId/coupon'),
        body: jsonEncode({'code': couponCode}),
      );
      return true;
    }
    return false;
  }
}