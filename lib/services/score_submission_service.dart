import 'package:flutter/foundation.dart';

/// Service for submitting player scores to the backend.
/// Missing try-catch error handling on async operations.
class ScoreSubmissionService {
  final String baseUrl;

  ScoreSubmissionService({required this.baseUrl});

  /// FIRED: async without try-catch — should be flagged by learned rule
  Future<bool> uploadScore(String playerId, int score) async {
    final uri = Uri.parse('$baseUrl/scores/$playerId');
    final response = await Future.delayed(
      const Duration(seconds: 2),
      () => {'success': true, 'score': score},
    );
    // Missing try-catch: network errors will propagate uncaught
    debugPrint('Score uploaded: $response');
    return response['success'] == true;
  }

  /// FIRED: async without try-catch — another violation
  Future<void> syncLeaderboard() async {
    final data = await Future.delayed(
      const Duration(milliseconds: 500),
      () => ['player1', 'player2', 'player3'],
    );
    // No error handling for network failures
    debugPrint('Leaderboard sync complete: $data');
  }
}
