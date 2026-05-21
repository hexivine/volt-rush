import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// Handles in-app purchases, receipt validation, and entitlement delivery.
class IAPService {
  final InAppPurchase _iap = InAppPurchase.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  static const Set<String> _productIds = {
    'credits_100',
    'credits_500',
    'credits_1000',
    'pro_monthly',
    'pro_yearly',
  };

  /// Initialize and listen for purchase updates
  void initialize(String userId) {
    _subscription = _iap.purchaseStream.listen(
      (purchases) => _handlePurchases(purchases, userId),
      onError: (error) => print('IAP stream error: $error'),
    );
  }

  /// Fetch available products from the store
  Future<List<ProductDetails>> getProducts() async {
    final available = await _iap.isAvailable();
    if (!available) return [];

    final response = await _iap.queryProductDetails(_productIds);
    return response.productDetails;
  }

  /// Initiate a purchase
  Future<bool> buyProduct(ProductDetails product) async {
    final purchaseParam = PurchaseParam(productDetails: product);

    if (product.id.contains('monthly') || product.id.contains('yearly')) {
      return _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } else {
      return _iap.buyConsumable(purchaseParam: purchaseParam);
    }
  }

  /// Handle completed purchases
  Future<void> _handlePurchases(List<PurchaseDetails> purchases, String userId) async {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        // Validate receipt server-side
        final valid = await _validateReceipt(purchase);

        if (valid) {
          await _deliverEntitlement(userId, purchase);
        }

        if (purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
        }
      } else if (purchase.status == PurchaseStatus.error) {
        print('Purchase error: ${purchase.error?.message}');
      }
    }
  }

  /// Validate purchase receipt with server
  Future<bool> _validateReceipt(PurchaseDetails purchase) async {
    // TODO: Call backend validation endpoint
    if (purchase.verificationData.serverVerificationData.isEmpty) {
      return false;
    }
    return true;
  }

  /// Deliver purchased entitlement to user
  Future<void> _deliverEntitlement(String userId, PurchaseDetails purchase) async {
    final userRef = _db.collection('users').doc(userId);

    switch (purchase.productID) {
      case 'credits_100':
        await userRef.update({'credits': FieldValue.increment(100)});
        break;
      case 'credits_500':
        await userRef.update({'credits': FieldValue.increment(500)});
        break;
      case 'credits_1000':
        await userRef.update({'credits': FieldValue.increment(1000)});
        break;
      case 'pro_monthly':
      case 'pro_yearly':
        await userRef.update({
          'tier': 'pro',
          'subscriptionExpiry': DateTime.now().add(
            purchase.productID == 'pro_yearly'
                ? const Duration(days: 365)
                : const Duration(days: 30),
          ).toIso8601String(),
        });
        break;
    }

    // Record transaction
    await _db.collection('transactions').add({
      'userId': userId,
      'productId': purchase.productID,
      'purchaseId': purchase.purchaseID,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'delivered',
    });
  }

  /// Restore previous purchases
  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }

  /// Dispose subscription
  void dispose() {
    _subscription?.cancel();
  }
}
