import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:volt_rush/providers/auth_provider.dart';
import 'package:volt_rush/services/rewards_service.dart';

/// Screen showing daily reward streak and claim button.
class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  final RewardsService _service = RewardsService();
  Map<String, dynamic>? _streakInfo;
  bool _claiming = false;
  int? _earnedMultiplier;

  @override
  void initState() {
    super.initState();
    _loadStreak();
  }

  Future<void> _loadStreak() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.user?.uid;
    if (userId == null) return;

    final info = await _service.getStreakInfo(userId);
    setState(() => _streakInfo = info);
  }

  Future<void> _claimReward() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.user?.uid;
    if (userId == null) return;

    setState(() => _claiming = true);
    final multiplier = await _service.claimDailyReward(userId);
    setState(() {
      _claiming = false;
      _earnedMultiplier = multiplier;
    });
    await _loadStreak();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Rewards'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFF1A1A1A),
      body: Center(
        child: _streakInfo == null
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Streak display
                  Text(
                    '🔥 ${_streakInfo!['streak']} Day Streak',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${_streakInfo!['multiplier']}x Score Multiplier',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.amber.shade300,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Claim button or countdown
                  if (_streakInfo!['canClaim'] == true)
                    ElevatedButton(
                      onPressed: _claiming ? null : _claimReward,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      ),
                      child: _claiming
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Claim Daily Reward', style: TextStyle(fontSize: 16)),
                    )
                  else
                    Text(
                      'Next reward in ${_streakInfo!['hoursUntilClaim']}h',
                      style: const TextStyle(fontSize: 16, color: Colors.white54),
                    ),

                  // Result
                  if (_earnedMultiplier != null && _earnedMultiplier! > 0) ...[
                    const SizedBox(height: 24),
                    Text(
                      '🎉 Earned ${_earnedMultiplier}x multiplier!',
                      style: const TextStyle(fontSize: 20, color: Colors.greenAccent),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}
