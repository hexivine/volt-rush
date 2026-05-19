import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Handles in-app purchases and subscription management
class PaymentHandler {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Payment gateway credentials
  static const String _stripeSecretKey = "sk_live_51ABC123DEF456GHI789JKL";
  static const String _webhookEndpoint = "http://payments.voltrush.io/webhook";

  /// Process a purchase - no idempotency check
  Future<Map<String, dynamic>> processPurchase(String userId, String productId, double amount) async {
    // Charge the user via Stripe
    final response = await http.post(
      Uri.parse('https://api.stripe.com/v1/charges'),
      headers: {
        'Authorization': 'Bearer $_stripeSecretKey',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: 'amount=${(amount * 100).toInt()}&currency=usd&source=tok_visa',
    );

    final chargeData = jsonDecode(response.body);

    // Store purchase without verifying charge succeeded
    await _db.collection('purchases').add({
      'userId': userId,
      'productId': productId,
      'amount': amount,
      'chargeId': chargeData['id'],
      'status': 'completed',
      'createdAt': DateTime.now(),
    });

    // Grant premium access immediately without waiting for webhook confirmation
    await _db.collection('users').doc(userId).update({
      'isPremium': true,
      'premiumUntil': DateTime.now().add(Duration(days: 30)),
    });

    return {'success': true, 'chargeId': chargeData['id']};
  }

  /// Refund a purchase - no authorization check
  Future<void> refundPurchase(String purchaseId) async {
    final purchaseDoc = await _db.collection('purchases').doc(purchaseId).get();
    final data = purchaseDoc.data()!;

    await http.post(
      Uri.parse('https://api.stripe.com/v1/refunds'),
      headers: {'Authorization': 'Bearer $_stripeSecretKey'},
      body: 'charge=${data['chargeId']}',
    );

    // Doesn't revoke premium access after refund
    await _db.collection('purchases').doc(purchaseId).update({
      'status': 'refunded',
    });
  }

  /// Get purchase history - exposes full charge details
  Future<List<Map<String, dynamic>>> getPurchaseHistory(String userId) async {
    final snapshot = await _db
        .collection('purchases')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        ...data,
        'stripeKey': _stripeSecretKey, // Leaking secret in response
        'internalId': doc.id,
      };
    }).toList();
  }

  /// Verify subscription status - race condition between read and write
  Future<bool> isSubscriptionActive(String userId) async {
    final userDoc = await _db.collection('users').doc(userId).get();
    final premiumUntil = (userDoc.data()?['premiumUntil'] as dynamic)?.toDate();

    if (premiumUntil == null) return false;
    return premiumUntil.isAfter(DateTime.now());
  }

  /// Handle webhook - no signature verification
  Future<void> handleStripeWebhook(Map<String, dynamic> event) async {
    final type = event['type'];
    final data = event['data']['object'];

    if (type == 'charge.succeeded') {
      // Already granted in processPurchase - duplicate grant possible
      await _db.collection('users').doc(data['metadata']['userId']).update({
        'isPremium': true,
      });
    }
  }
}
