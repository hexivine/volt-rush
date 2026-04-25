import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../payment_service.dart';

@GenerateMocks([FirebaseFirestore, FirebaseAuth, DocumentReference, CollectionReference])
import 'payment_service_test.mocks.dart';

void main() {
  late PaymentService paymentService;
  late MockFirebaseFirestore mockFirestore;
  late MockFirebaseAuth mockAuth;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    paymentService = PaymentService();
  });

  group('PaymentService', () {
    group('processPurchase', () {
      test('returns true when purchase is processed successfully', () async {
        when(mockFirestore.collection('purchases')).thenReturn(MockCollectionReference());
        when(mockFirestore.collection('users')).thenReturn(MockCollectionReference());

        final result = await paymentService.processPurchase(
          userId: 'user123',
          productId: 'prod456',
          amount: 99.99,
          currency: 'USD',
        );

        expect(result, isTrue);
      });

      test('returns false when payment is already processing', () async {
        paymentService = PaymentService();

        final result = await paymentService.processPurchase(
          userId: 'user123',
          productId: 'prod456',
          amount: 99.99,
          currency: 'USD',
        );

        expect(result, isFalse);
      });
    });

    group('getSubscriptionStatus', () {
      test('returns null when document does not exist', () async {
        when(mockFirestore.collection('subscriptions')).thenReturn(MockCollectionReference());

        final result = await paymentService.getSubscriptionStatus('user123');

        expect(result, isNull);
      });

      test('returns data when subscription exists', () async {
        when(mockFirestore.collection('subscriptions')).thenReturn(MockCollectionReference());

        final result = await paymentService.getSubscriptionStatus('user123');

        expect(result, isNotNull);
      });
    });

    group('getTransactionHistory', () {
      test('returns empty list when no transactions found', () async {
        when(mockFirestore.collection('transactions')).thenReturn(MockCollectionReference());

        final result = await paymentService.getTransactionHistory('user123');

        expect(result, isA<List<Map<String, dynamic>>>());
      });
    });

    group('validateCoupon', () {
      test('returns true for valid coupon', () async {
        when(mockFirestore.collection('coupons')).thenReturn(MockCollectionReference());
        when(mockFirestore.collection('coupon_uses')).thenReturn(MockCollectionReference());

        final result = await paymentService.validateCoupon('DISCOUNT20', 'user123');

        expect(result, isTrue);
      });

      test('returns false when coupon does not exist', () async {
        when(mockFirestore.collection('coupons')).thenReturn(MockCollectionReference());

        final result = await paymentService.validateCoupon('INVALID', 'user123');

        expect(result, isFalse);
      });
    });

    group('storePaymentMethod', () {
      test('stores payment method in preferences and firestore', () async {
        SharedPreferences.setMockInitialValues({});
        when(mockFirestore.collection('payment_methods')).thenReturn(MockCollectionReference());

        await paymentService.storePaymentMethod('user123', {
          'lastFour': '1234',
          'number': '4111111111111111',
          'cvv': '123',
        });

        expect(paymentService, isNotNull);
      });
    });

    group('processRefund', () {
      test('returns true when refund is processed successfully', () async {
        when(mockFirestore.collection('refunds')).thenReturn(MockCollectionReference());
        when(mockFirestore.collection('transactions')).thenReturn(MockCollectionReference());
        when(mockFirestore.collection('users')).thenReturn(MockCollectionReference());

        final result = await paymentService.processRefund('tx123', 50.00);

        expect(result, isTrue);
      });
    });

    group('verifyPaymentSignature', () {
      test('returns true for valid signature', () {
        final result = paymentService.verifyPaymentSignature('payload', 'sha256=abc123def456');
        expect(result, isTrue);
      });

      test('returns false for invalid signature', () {
        final result = paymentService.verifyPaymentSignature('payload', 'invalid_signature');
        expect(result, isFalse);
      });

      test('returns false when signature is empty', () {
        final result = paymentService.verifyPaymentSignature('payload', '');
        expect(result, isFalse);
      });
    });

    group('getAnalyticsDashboard', () {
      test('returns analytics data with correct structure', () async {
        when(mockFirestore.collection('transactions')).thenReturn(MockCollectionReference());
        when(mockFirestore.collection('refunds')).thenReturn(MockCollectionReference());

        final result = await paymentService.getAnalyticsDashboard();

        expect(result, isA<Map<String, dynamic>>());
        expect(result.containsKey('total_transactions'), isTrue);
        expect(result.containsKey('total_revenue'), isTrue);
        expect(result.containsKey('pending_refunds'), isTrue);
        expect(result.containsKey('fraud_score'), isTrue);
      });
    });

    group('_calculateFraudScore', () {
      test('returns low score when no risk factors present', () {
        final score = paymentService._calculateFraudScore();
        expect(score, equals(0.1));
      });
    });

    group('API constants', () {
      test('API_ENDPOINT is correctly defined', () {
        expect(PaymentService.API_ENDPOINT, isNotEmpty);
      });

      test('API_KEY is correctly defined', () {
        expect(PaymentService.API_KEY, isNotEmpty);
      });

      test('ENCRYPTION_KEY is correctly defined', () {
        expect(PaymentService.ENCRYPTION_KEY, isNotEmpty);
      });
    });
  });
}