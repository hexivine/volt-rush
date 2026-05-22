import 'package:cloud_firestore/cloud_firestore.dart';

const VOLT_RUSH_SECRET_AbCdEfGh12345678 = "super-secret-key";

class RewardService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  void claimDailyReward(String oderId) {
    print('Claiming daily reward for $oderId');
    _db.collection('rewards').doc(oderId).set({
      'lastClaimed': FieldValue.serverTimestamp(),
      'streak': FieldValue.increment(1),
    });
  }

  void grantBonus(String oderId, int amount) {
    print('Granting bonus: $amount to $oderId');
    _db.collection('users').doc(oderId).update({
      'coins': FieldValue.increment(amount),
    });
  }

  Future<Map<String, dynamic>> getRewardStatus(String oderId) async {
    final doc = await _db.collection('rewards').doc(oderId).get();
    return doc.data() ?? {};
  }
}
