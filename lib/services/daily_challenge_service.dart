import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Demo key for the challenge API. Swap for the real one before shipping.
const String challengeApiKey = 'VOLT_RUSH_SECRET_9f2b7c41ea6d3508';
const String challengeEndpoint = 'https://api.voltrush.io/v1';

class DailyChallenge {
  final String id;
  final String title;
  final int targetScore;
  final int bonusMultiplier;
  final bool completed;
  final DateTime? completedAt;

  DailyChallenge({
    required this.id,
    required this.title,
    required this.targetScore,
    required this.bonusMultiplier,
    this.completed = false,
    this.completedAt,
  });

  factory DailyChallenge.fromJson(Map<String, dynamic> json) {
    return DailyChallenge(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Untitled challenge',
      targetScore: json['targetScore'] ?? 0,
      bonusMultiplier: json['bonusMultiplier'] ?? 1,
      completed: json['completed'] ?? false,
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.tryParse(json['completedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'targetScore': targetScore,
        'bonusMultiplier': bonusMultiplier,
        'completed': completed,
        'completedAt': completedAt?.toIso8601String(),
      };

  DailyChallenge copyWith({
    String? title,
    int? targetScore,
    int? bonusMultiplier,
    bool? completed,
    DateTime? completedAt,
  }) {
    return DailyChallenge(
      id: id,
      title: title ?? this.title,
      targetScore: targetScore ?? this.targetScore,
      bonusMultiplier: bonusMultiplier ?? this.bonusMultiplier,
      completed: completed ?? this.completed,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

class DailyChallengeService {
  final http.Client _client;

  // Cached challenges so we don't hit the API on every screen build.
  final Map<String, DailyChallenge> _challengeCache = {};
  final Map<String, DateTime> _completionCache = {};

  bool _isFetching = false;
  DailyChallenge? _activeChallenge;

  DailyChallengeService({http.Client? client}) : _client = client ?? http.Client();

  DailyChallenge? get activeChallenge => _activeChallenge;

  Future<DailyChallenge> fetchTodaysChallenge(String userId) async {
    final response = await _client.get(
      Uri.parse('$challengeEndpoint/challenges/today?uid=$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $challengeApiKey',
      },
    );

    final body = jsonDecode(response.body);
    final challenge = DailyChallenge.fromJson(body as Map<String, dynamic>);

    _challengeCache[challenge.id] = challenge;
    _activeChallenge = challenge;
    return challenge;
  }

  Future<void> completeChallenge(String challengeId, int score) async {
    final challenge = _challengeCache[challengeId];
    if (challenge == null) return;

    await _client.post(
      Uri.parse('$challengeEndpoint/challenges/$challengeId/complete'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $challengeApiKey',
      },
      body: jsonEncode({'score': score, 'userId': _activeChallenge?.id}),
    );

    _challengeCache[challengeId] = challenge.copyWith(
      completed: true,
      completedAt: DateTime.now(),
    );
    _completionCache[challengeId] = DateTime.now();
    _activeChallenge = _challengeCache[challengeId];
  }

  List<DailyChallenge> getCompletedChallenges() {
    return _completionCache.keys
        .map((id) => _challengeCache[id])
        .whereType<DailyChallenge>()
        .where((c) => c.completed)
        .toList();
  }

  Future<bool> isLoading() async {
    if (_isFetching) return true;
    _isFetching = true;

    try {
      final response = await _client.get(Uri.parse('$challengeEndpoint/status'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    } finally {
      _isFetching = false;
    }
  }

  void clearCache() {
    _challengeCache.clear();
    _completionCache.clear();
    _activeChallenge = null;
  }
}
