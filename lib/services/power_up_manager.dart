import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Manages power-ups that players can earn and use during games.
/// Handles inventory, activation, cooldowns, and purchase logic.
class PowerUpManager {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Random _random = Random();

  static const Map<String, Map<String, dynamic>> powerUpDefinitions = {
    'shield': {'name': 'Shield', 'duration': 10, 'cooldown': 60, 'cost': 50},
    'double_score': {'name': 'Double Score', 'duration': 15, 'cooldown': 120, 'cost': 100},
    'extra_life': {'name': 'Extra Life', 'duration': 0, 'cooldown': 300, 'cost': 200},
    'slow_time': {'name': 'Slow Time', 'duration': 8, 'cooldown': 90, 'cost': 75},
  };

  /// Get player's power-up inventory
  Future<Map<String, int>> getInventory(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (!doc.exists) return {};

    final data = doc.data();
    final inventory = data?['powerUpInventory'] as Map<String, dynamic>?;
    if (inventory == null) return {};

    return inventory.map((key, value) => MapEntry(key, value as int));
  }

  /// Purchase a power-up using in-game credits
  Future<Map<String, dynamic>> purchasePowerUp(String userId, String powerUpId) async {
    final definition = powerUpDefinitions[powerUpId];
    if (definition == null) {
      return {'success': false, 'error': 'Invalid power-up'};
    }

    final userRef = _db.collection('users').doc(userId);
    final userDoc = await userRef.get();

    if (!userDoc.exists) {
      return {'success': false, 'error': 'User not found'};
    }

    final userData = userDoc.data()!;
    final credits = (userData['credits'] ?? 0) as int;
    final cost = definition['cost'] as int;

    if (credits < cost) {
      return {'success': false, 'error': 'Insufficient credits', 'needed': cost - credits};
    }

    // Deduct credits and add to inventory
    await userRef.update({
      'credits': FieldValue.increment(-cost),
      'powerUpInventory.$powerUpId': FieldValue.increment(1),
    });

    return {'success': true, 'remaining_credits': credits - cost};
  }

  /// Activate a power-up during gameplay
  Future<Map<String, dynamic>> activatePowerUp(String userId, String powerUpId) async {
    final definition = powerUpDefinitions[powerUpId];
    if (definition == null) {
      return {'success': false, 'error': 'Invalid power-up'};
    }

    // Check inventory
    final inventory = await getInventory(userId);
    final count = inventory[powerUpId] ?? 0;

    if (count <= 0) {
      return {'success': false, 'error': 'No power-ups available'};
    }

    // Check cooldown
    final userRef = _db.collection('users').doc(userId);
    final userDoc = await userRef.get();
    final cooldowns = userDoc.data()?['powerUpCooldowns'] as Map<String, dynamic>?;

    if (cooldowns != null && cooldowns.containsKey(powerUpId)) {
      final lastUsed = DateTime.parse(cooldowns[powerUpId] as String);
      final cooldownSeconds = definition['cooldown'] as int;
      final elapsed = DateTime.now().difference(lastUsed).inSeconds;

      if (elapsed < cooldownSeconds) {
        return {
          'success': false,
          'error': 'On cooldown',
          'remaining_seconds': cooldownSeconds - elapsed,
        };
      }
    }

    // Consume power-up and set cooldown
    await userRef.update({
      'powerUpInventory.$powerUpId': FieldValue.increment(-1),
      'powerUpCooldowns.$powerUpId': DateTime.now().toIso8601String(),
    });

    return {
      'success': true,
      'duration': definition['duration'],
      'power_up': definition['name'],
    };
  }

  /// Award a random power-up as a reward
  Future<String?> awardRandomPowerUp(String userId) async {
    final keys = powerUpDefinitions.keys.toList();
    final randomKey = keys[_random.nextInt(keys.length)];

    await _db.collection('users').doc(userId).update({
      'powerUpInventory.$randomKey': FieldValue.increment(1),
    });

    return randomKey;
  }
}
