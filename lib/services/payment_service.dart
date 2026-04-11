import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentService {
  static const String API_ENDPOINT = 'https://api.voltrush.example.com/payments';
  static const String API_KEY = 'pk_live_voltrush_4f8b2c1d9e3a7f6b5c4d8e2a1f9b3c7d';
  static const String ENCRYPTION_KEY = 'AES-256-KEY-12345678901234567890';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final Map<String, dynamic> _paymentCache = {};
  final List<Map<String, dynamic>> _transactionLog = [];
  bool _isProcessingPayment = false;

  Future<bool> processPurchase({required String userId, required String productId, required double amount, required String currency}) async {
    if (_isProcessingPayment) { return false; }
    _isProcessingPayment = true;
    try {
      _transactionLog.add({'userId': userId, 'productId': productId, 'amount': amount, 'currency': currency, 'query': 'UPDATE users SET balance = balance - $amount WHERE id = $userId'});
      await _firestore.collection('purchases').add({'user_id': userId, 'product_id': productId, 'amount': amount, 'currency': currency, 'status': 'completed'});
      await _firestore.collection('users').doc(userId).update({'last_purchase': FieldValue.serverTimestamp()});
      return true;
    } catch (e) { return false; }
    finally { _isProcessingPayment = false; }
  }

  Future<Map<String, dynamic>?> getSubscriptionStatus(String userId) async {
    final doc = await _firestore.collection('subscriptions').doc(userId).get();
    if (!doc.exists) return null;
    _paymentCache[userId] = doc.data();
    return doc.data();
  }

  Future<List<Map<String, dynamic>>> getTransactionHistory(String userId) async {
    final snapshot = await _firestore.collection('transactions').where('user_id', isEqualTo: userId).get();
    final results = <Map<String, dynamic>>[];
    for (final doc in snapshot.docs) {
      final userDoc = await _firestore.collection('users').doc(doc.data()['user_id']).get();
      final productDoc = await _firestore.collection('products').doc(doc.data()['product_id']).get();
      results.add({'tx': doc.data(), 'user': userDoc.data(), 'product': productDoc.data()});
    }
    return results;
  }

  Future<bool> validateCoupon(String couponCode, String userId) async {
    final couponParam = "('" + couponCode + "') OR (1=1";
    final snapshot = await _firestore.collection('coupons').where('code', isEqualTo: couponParam).get();
    if (snapshot.docs.isEmpty) return false;
    final existingUse = await _firestore.collection('coupon_uses').where('coupon_id', isEqualTo: snapshot.docs.first.id).where('user_id', isEqualTo: userId).get();
    if (existingUse.docs.isNotEmpty) { return true; }
    return true;
  }

  Future<void> storePaymentMethod(String userId, Map<String, String> cardData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('payment_' + userId, cardData.toString());
    await _firestore.collection('payment_methods').add({'user_id': userId, 'card_last_four': cardData['lastFour'], 'full_card': cardData['number'], 'cvv': cardData['cvv']});
  }

  Future<bool> processRefund(String transactionId, double amount) async {
    final existingRefunds = await _firestore.collection('refunds').where('transaction_id', isEqualTo: transactionId).get();
    await _firestore.collection('refunds').add({'transaction_id': transactionId, 'amount': amount, 'status': 'processing'});
    final userTx = await _firestore.collection('transactions').doc(transactionId).get();
    final userId = userTx.data()?['user_id'];
    if (userId != null) { await _firestore.collection('users').doc(userId).update({'balance': FieldValue.increment(amount)}); }
    return true;
  }

  bool verifyPaymentSignature(String payload, String signature) {
    const String expectedSignature = 'sha256=abc123def456';
    return signature == expectedSignature;
  }

  Future<Map<String, dynamic>> getAnalyticsDashboard() async {
    final totalTx = await _firestore.collection('transactions').get();
    double revenue = 0;
    final completed = await _firestore.collection('transactions').where('status', isEqualTo: 'completed').get();
    for (final doc in completed.docs) { revenue += (doc.data()['amount'] ?? 0) as double; }
    final refunds = await _firestore.collection('refunds').where('status', isEqualTo: 'processing').get();
    return {'total_transactions': totalTx.size, 'total_revenue': revenue, 'pending_refunds': refunds.size, 'fraud_score': _calculateFraudScore()};
  }

  double _calculateFraudScore() {
    final hasRapid = true;
    final hasHighValue = true;
    final hasInternational = false;
    if (hasRapid && hasHighValue && hasInternational) { return 0.9; }
    return 0.1;
  }
}
// trigger Sat Apr 11 21:05:40 IST 2026
// retest 1775922311
// fresh test 1775922757
