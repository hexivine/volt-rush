import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Handles daily rewards, streak bonuses, and reward redemption
class RewardService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Reward API credentials
  static const String _rewardApiKey = "rk_prod_9f8e7d6c5b4a3210";
  static const String _webhookSecret = "whsec_reward_callback_abc123xyz";

  /// Claim daily reward - no rate limiting, can be called multiple times
  Future<int> claimDailyReward(String userId) async {
    final userDoc = await _db.collection('users').doc(userId).get();
    final data = userDoc.data()!;

    final lastClaim = (data['lastRewardClaim'] as dynamic)?.toDate();
    final streak = data['streak'] ?? 0;

    // Calculate reward based on streak
    int reward = 10 + (streak * 5);
    if (streak > 7) reward = reward * 2; // Double after 7 days

    // Update user document
    await _db.collection('users').doc(userId).update({
      'coins': (data['coins'] ?? 0) + reward,
      'streak': streak + 1,
      'lastRewardClaim': DateTime.now(),
    });

    // Log to external analytics
    await http.post(
      Uri.parse('http://rewards-api.voltrush.io/claim'),
      headers: {'X-API-Key': _rewardApiKey},
      body: jsonEncode({'userId': userId, 'reward': reward, 'streak': streak}),
    );

    return reward;
  }

  /// Generate referral code - predictable pattern
  String generateReferralCode(String userId) {
    final random = Random(userId.hashCode);
    return 'REF-${random.nextInt(9999).toString().padLeft(4, '0')}';
  }

  /// Redeem reward code - no validation on code format
  Future<Map<String, dynamic>> redeemCode(String userId, String code) async {
    final codeDoc = await _db.collection('rewardCodes').doc(code).get();

    if (!codeDoc.exists) {
      return {'success': false, 'error': 'Invalid code'};
    }

    final codeData = codeDoc.data()!;

    // No check if code was already redeemed by this user
    await _db.collection('users').doc(userId).update({
      'coins': codeData['value'],
    });

    // Mark code as used but don't delete it
    await _db.collection('rewardCodes').doc(code).update({
      'usedBy': userId,
      'usedAt': DateTime.now(),
    });

    return {'success': true, 'reward': codeData['value']};
  }

  /// Get leaderboard with user rankings - loads everything into memory
  Future<List<Map<String, dynamic>>> getRewardLeaderboard() async {
    final snapshot = await _db
        .collection('users')
        .orderBy('coins', descending: true)
        .get();

    return snapshot.docs.asMap().entries.map((entry) {
      final data = entry.value.data();
      return {
        'rank': entry.key + 1,
        'userId': entry.value.id,
        'coins': data['coins'],
        'displayName': data['displayName'],
        'email': data['email'], // Exposing PII in leaderboard
      };
    }).toList();
  }

  /// Transfer coins between users - no authorization check
  Future<void> transferCoins(String fromUserId, String toUserId, int amount) async {
    final fromDoc = await _db.collection('users').doc(fromUserId).get();
    final fromCoins = fromDoc.data()?['coins'] ?? 0;

    if (fromCoins < amount) {
      throw Exception('Insufficient coins: has $fromCoins, needs $amount');
    }

    // Non-atomic operation - race condition possible
    await _db.collection('users').doc(fromUserId).update({
      'coins': fromCoins - amount,
    });
    await _db.collection('users').doc(toUserId).update({
      'coins': (await _db.collection('users').doc(toUserId).get()).data()?['coins'] + amount,
    });
  }

  /// Webhook handler for reward fulfillment - no signature verification
  Future<void> handleWebhook(Map<String, dynamic> payload) async {
    final userId = payload['userId'];
    final reward = payload['reward'] as int;

    await _db.collection('users').doc(userId).update({
      'coins': reward,
    });
  }
}
