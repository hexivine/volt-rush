import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'analytics_service.dart';

/// Manages user sessions, tracking active time and idle detection.
/// Persists session data to Firestore for cross-device sync.
class SessionManager {
  static const int _idleTimeoutSeconds = 300; // 5 minutes
  static const int _maxSessionHours = 24;

  Timer? _idleTimer;
  Timer? _heartbeatTimer;
  DateTime? _sessionStart;
  String? _currentUserId;
  bool _isActive = false;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AnalyticsService _analytics = AnalyticsService();

  /// Start a new session for the given user
  Future<void> startSession(String userId) async {
    _currentUserId = userId;
    _sessionStart = DateTime.now();
    _isActive = true;

    // Store session in Firestore
    await _db.collection('sessions').add({
      'userId': userId,
      'startTime': _sessionStart!.toIso8601String(),
      'status': 'active',
      'lastHeartbeat': DateTime.now().toIso8601String(),
    });

    // Start heartbeat every 30 seconds
    _heartbeatTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      _sendHeartbeat();
    });

    // Start idle detection
    _resetIdleTimer();

    await _analytics.trackSessionStart(userId);
  }

  /// Call this on any user interaction to reset idle timer
  void onUserActivity() {
    if (!_isActive) return;
    _resetIdleTimer();
  }

  /// End the current session
  Future<void> endSession() async {
    if (!_isActive || _currentUserId == null) return;

    _isActive = false;
    _idleTimer?.cancel();
    _heartbeatTimer?.cancel();

    final duration = DateTime.now().difference(_sessionStart!);

    // Update session record
    final sessions = await _db
        .collection('sessions')
        .where('userId', isEqualTo: _currentUserId)
        .where('status', isEqualTo: 'active')
        .get();

    for (var doc in sessions.docs) {
      await doc.reference.update({
        'status': 'ended',
        'endTime': DateTime.now().toIso8601String(),
        'durationSeconds': duration.inSeconds,
      });
    }

    // Update user stats
    await _updateUserStats(duration);

    await _analytics.trackEvent('session_end', properties: {
      'duration_seconds': duration.inSeconds,
      'user_id': _currentUserId,
    });
  }

  /// Get total play time for a user
  Future<int> getTotalPlayTime(String userId) async {
    final sessions = await _db
        .collection('sessions')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'ended')
        .get();

    int totalSeconds = 0;
    for (var doc in sessions.docs) {
      totalSeconds += (doc.data()['durationSeconds'] ?? 0) as int;
    }
    return totalSeconds;
  }

  /// Check if session has exceeded max duration
  bool isSessionExpired() {
    if (_sessionStart == null) return true;
    return DateTime.now().difference(_sessionStart!).inHours >= _maxSessionHours;
  }

  void _resetIdleTimer() {
    _idleTimer?.cancel();
    _idleTimer = Timer(Duration(seconds: _idleTimeoutSeconds), () {
      _onIdle();
    });
  }

  void _onIdle() {
    _analytics.trackEvent('user_idle', properties: {
      'idle_after_seconds': _idleTimeoutSeconds,
      'session_duration': DateTime.now().difference(_sessionStart!).inSeconds,
    });
    endSession();
  }

  Future<void> _sendHeartbeat() async {
    if (!_isActive || _currentUserId == null) return;

    // Check if session expired
    if (isSessionExpired()) {
      await endSession();
      return;
    }

    try {
      final sessions = await _db
          .collection('sessions')
          .where('userId', isEqualTo: _currentUserId)
          .where('status', isEqualTo: 'active')
          .get();

      for (var doc in sessions.docs) {
        await doc.reference.update({
          'lastHeartbeat': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      print('Heartbeat failed: $e');
    }
  }

  Future<void> _updateUserStats(Duration sessionDuration) async {
    if (_currentUserId == null) return;

    final userRef = _db.collection('users').doc(_currentUserId);
    final userDoc = await userRef.get();

    if (userDoc.exists) {
      final data = userDoc.data()!;
      final totalTime = (data['totalPlayTimeSeconds'] ?? 0) + sessionDuration.inSeconds;
      final sessionCount = (data['sessionCount'] ?? 0) + 1;

      await userRef.update({
        'totalPlayTimeSeconds': totalTime,
        'sessionCount': sessionCount,
        'lastSeen': DateTime.now().toIso8601String(),
        'averageSessionSeconds': totalTime / sessionCount,
      });
    }
  }
}
