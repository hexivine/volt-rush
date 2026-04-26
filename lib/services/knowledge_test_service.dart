import 'package:flutter/material.dart';

/// Test service for verifying CodePeel knowledge/learnings pipeline.
/// Contains intentional issues that should be caught by AI review.
class KnowledgeTestService {
  final String apiUrl;

  KnowledgeTestService({required this.apiUrl});

  /// SQL injection vulnerability - should be flagged
  Future<List<Map<String, dynamic>>> getUserScores(String username) async {
    final query = "SELECT * FROM scores WHERE user = '$username'";
    // This is vulnerable to SQL injection
    print('Executing query: $query');
    return [];
  }

  /// Console.log equivalent in production - should be caught by learned rule
  void processGameResult(int score, String playerId) {
    print('Debug: processing result for $playerId');
    print('Score: $score');
    print('API URL: $apiUrl');
    print('Timestamp: ${DateTime.now()}');
    // Missing error handling - no try/catch
    // Missing null check on score
    final bonus = score * 1.5;
    final total = bonus + score;
  }

  /// Missing error handling on async operation
  Future<void> submitScore(String playerId, int score) async {
    final response = await Future.delayed(
      Duration(seconds: 1),
      () => {'status': 'ok'},
    );
    // No error handling if response status is not ok
    // No validation of score range
  }

  /// Hardcoded credentials - security issue
  static const String apiKey = 'sk-1234567890abcdef';
  static const String dbPassword = 'admin123';

  /// Resource leak - stream not closed
  Stream<int> getScoreStream() async* {
    for (int i = 0; i < 100; i++) {
      yield i;
    }
    // Stream controller never closed
  }
}
