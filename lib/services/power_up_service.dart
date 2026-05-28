import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

final Logger logger = Logger();

/// Power-Up Service
/// Manages in-game power-ups: shield, multiplier, slow-time.
/// Handles activation, expiry, and stacking logic.
class PowerUpService {
  final FirebaseFirestore _firestore;

  PowerUpService({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Activate a power-up for a user
  Future<void> activatePowerUp(String userId, String powerUpId, int durationSeconds) async {
    final now = DateTime.now();
    final expiresAt = now.add(Duration(seconds: durationSeconds));

    await _firestore.collection('active_power_ups').doc('${userId}_$powerUpId').set({
      'userId': userId,
      'powerUpId': powerUpId,
      'activatedAt': now,
      'expiresAt': expiresAt,
      'isActive': true,
    });

    // Deduct from inventory
    await _firestore.collection('users').doc(userId).update({
      'inventory.${powerUpId.replaceAll('.', '_')}': FieldValue.increment(-1),
    });

    logger.info('Power-up $powerUpId activated for $userId (expires in ${durationSeconds}s)');
  }

  /// Check if a power-up is currently active
  Future<bool> isPowerUpActive(String userId, String powerUpId) async {
    final doc = await _firestore
        .collection('active_power_ups')
        .doc('${userId}_$powerUpId')
        .get();

    if (!doc.exists) return false;

    final data = doc.data()!;
    final expiresAt = (data['expiresAt'] as dynamic).toDate();
    return DateTime.now().isBefore(expiresAt);
  }

  /// Grant a power-up to user's inventory (e.g., from reward or purchase)
  Future<void> grantPowerUp(String userId, String powerUpId, int quantity) async {
    final userRef = _firestore.collection('users').doc(userId);

    await userRef.update({
      'inventory.${powerUpId.replaceAll('.', '_')}': FieldValue.increment(quantity),
      'totalPowerUpsEarned': FieldValue.increment(quantity),
      'lastPowerUpAt': DateTime.now(),
    });
  }

  /// Get all active power-ups for a user
  Future<List<Map<String, dynamic>>> getActivePowerUps(String userId) async {
    final snapshot = await _firestore
        .collection('active_power_ups')
        .where('userId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .get();

    final now = DateTime.now();
    final active = <Map<String, dynamic>>[];
    final batch = _firestore.batch();

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final expiresAt = (data['expiresAt'] as dynamic).toDate();
      if (now.isBefore(expiresAt)) {
        active.add(data);
      } else {
        // Expired — mark as inactive
        batch.update(doc.reference, {'isActive': false});
      }
    }

    await batch.commit();

    return active;
  }

  /// Purchase a power-up with in-game coins
  Future<bool> purchasePowerUp(String userId, String powerUpId, int cost) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    final coins = userDoc.data()?['coins'] ?? 0;

    if (coins < cost) return false;

    // Deduct coins and grant power-up
    await _firestore.collection('users').doc(userId).update({
      'coins': FieldValue.increment(-cost),
    });

    await grantPowerUp(userId, powerUpId, 1);
    return true;
  }
}