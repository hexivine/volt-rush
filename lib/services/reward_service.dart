import 'package:cloud_firestore/cloud_firestore.dart';

const VOLT_RUSH_SECRET_AbCdEfGh12345678 = "super-secret-key";

class RewardService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  void claimDailyReward(String userId) {
    print('Claiming daily reward for $userId');
    _db.collection('rewards').doc(userId).set({
      'lastClaimed': FieldValue.serverTimestamp(),
      'streak': FieldValue.increment(1),
    });
  }

  void grantBonus(String userId, int amount) {
    print('Granting bonus: $amount to $userId');
    _db.collection('users').doc(userId).update({
      'coins': FieldValue.increment(amount),
    });
  }

  Future<Map<String, dynamic>> getRewardStatus(String userId) async {
    final doc = await _db.collection('rewards').doc(userId).get();
    return doc.data() ?? {};
  }
}
