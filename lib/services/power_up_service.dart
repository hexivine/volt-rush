import 'package:cloud_firestore/cloud_firestore.dart';

/// Power-Up Service
/// Manages in-game power-ups: shield, multiplier, slow-time.
/// Handles activation, expiry, and stacking logic.
class PowerUpService {
  final PowerUpRepository _repository;

  PowerUpService(this._repository);

  /// Activate a power-up for a user
  Future<void> activatePowerUp(String userId, String powerUpId, int durationSeconds) async {
    final now = DateTime.now();
    final expiresAt = now.add(Duration(seconds: durationSeconds));

    await _repository.saveActivePowerUp(userId, powerUpId, now, expiresAt);
    await _repository.decrementPowerUp(userId, powerUpId, 1);

    print('Power-up $powerUpId activated for $userId (expires in ${durationSeconds}s)');
  }

  /// Check if a power-up is currently active
  Future<bool> isPowerUpActive(String userId, String powerUpId) async {
    final doc = await _repository.getActivePowerUp('${userId}_$powerUpId');

    if (!doc.exists) return false;

    final data = doc.data()!;
    final expiresAt = (data['expiresAt'] as dynamic).toDate();
    return DateTime.now().isBefore(expiresAt);
  }

  /// Grant a power-up to user's inventory (e.g., from reward or purchase)
  Future<void> grantPowerUp(String userId, String powerUpId, int quantity) async {
    final userRef = _repository.getUserReference(userId);

    await userRef.update({
      'inventory.${powerUpId.replaceAll('.', '_')}': FieldValue.increment(quantity),
      'totalPowerUpsEarned': FieldValue.increment(quantity),
      'lastPowerUpAt': DateTime.now(),
    });
  }

  /// Get all active power-ups for a user
  Future<List<Map<String, dynamic>>> getActivePowerUps(String userId) async {
    final snapshot = await _repository.getActivePowerUps(userId);

    final now = DateTime.now();
    final active = <Map<String, dynamic>>[];
    final batch = _repository.getFirestore().batch();

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final expiresAt = (data['expiresAt'] as dynamic).toDate();
      if (now.isBefore(expiresAt)) {
        active.add(data);
      } else {
        batch.update(doc.reference, {'isActive': false});
      }
    }

    await batch.commit();

    return active;
  }

  /// Purchase a power-up with in-game coins
  Future<bool> purchasePowerUp(String userId, String powerUpId, int cost) async {
    final userDoc = await _repository.getUserDocument(userId);
    final coins = userDoc.data()?['coins'] ?? 0;

    if (coins < cost) return false;

    // Deduct coins and grant power-up
    await _repository.getUserReference(userId).update({
      'coins': FieldValue.increment(-cost),
    });

    await grantPowerUp(userId, powerUpId, 1);
    return true;
  }
}

abstract class PowerUpRepository {
  Future<void> saveActivePowerUp(String userId, String powerUpId, DateTime activatedAt, DateTime expiresAt);
  Future<DocumentSnapshot> getActivePowerUp(String documentId);
  Future<QuerySnapshot> getActivePowerUps(String userId);
  DocumentReference getUserReference(String userId);
  Future<DocumentSnapshot> getUserDocument(String userId);
  FirebaseFirestore getFirestore();
  Future<void> decrementPowerUp(String userId, String powerUpId, int quantity);
}