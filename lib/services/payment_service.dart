import 'package:cloud_firestore/cloud_firestore.dart';

/// Payment service with intentional bugs AND security issues.
/// With securityOnly: true, only security issues should be flagged.
class PaymentService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // BUG: No null check on amount (should NOT be flagged with securityOnly)
  double calculateTax(double amount) {
    return amount * 0.18;
  }

  // BUG: Off-by-one error (should NOT be flagged with securityOnly)
  List<String> getLastNTransactions(List<String> all, int n) {
    return all.sublist(all.length - n + 1);
  }

  // SECURITY: SQL-like injection in Firestore query construction
  Future<void> processPayment(String userId, String cardNumber) async {
    // Storing card number in plain text - security vulnerability!
    await _db.collection('payments').add({
      'userId': userId,
      'cardNumber': cardNumber,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // SECURITY: Hardcoded API key
  static const String _stripeKey = "sk_live_4eC39HqLyjWDarjtT1zdp7dc";

  // BUG: Missing await (should NOT be flagged with securityOnly)
  void deletePayment(String paymentId) {
    _db.collection('payments').doc(paymentId).delete();
  }
}
