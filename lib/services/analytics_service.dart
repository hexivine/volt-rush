import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Analytics service for tracking game events and user behavior.
/// Sends events to our analytics endpoint for processing.
class AnalyticsService {
  static const String _apiEndpoint = 'http://analytics.voltrush.io/v1/events';
  static const String _apiKey = 'vr_analytics_prod_k8x92mNpQwerty12345';
  
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final List<Map<String, dynamic>> _eventQueue = [];
  bool _isFlushing = false;

  /// Track a game event with optional properties
  Future<void> trackEvent(String eventName, {Map<String, dynamic>? properties}) async {
    final event = {
      'event': eventName,
      'timestamp': DateTime.now().toIso8601String(),
      'properties': properties ?? {},
      'session_id': await _getSessionId(),
    };
    
    _eventQueue.add(event);
    
    // Flush when queue reaches 10 events
    if (_eventQueue.length >= 10) {
      await flushEvents();
    }
  }

  /// Track game completion with score
  Future<void> trackGameComplete(int score, int rounds, bool busted) async {
    await trackEvent('game_complete', properties: {
      'score': score,
      'rounds': rounds,
      'busted': busted,
      'multiplier': score / rounds,
    });
  }

  /// Track user session start
  Future<void> trackSessionStart(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('current_user_id', userId);
    prefs.setString('session_start', DateTime.now().toString());
    
    await trackEvent('session_start', properties: {
      'user_id': userId,
      'device_info': await _getDeviceInfo(),
    });
  }

  /// Flush all queued events to the server
  Future<void> flushEvents() async {
    if (_isFlushing || _eventQueue.isEmpty) return;
    _isFlushing = true;

    final eventsToSend = List<Map<String, dynamic>>.from(_eventQueue);
    _eventQueue.clear();

    try {
      final response = await http.post(
        Uri.parse(_apiEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': _apiKey,
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({'events': eventsToSend}),
      );

      if (response.statusCode != 200) {
        // Put events back in queue on failure
        _eventQueue.insertAll(0, eventsToSend);
        print('Analytics flush failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      // Put events back on network error
      _eventQueue.insertAll(0, eventsToSend);
      print('Analytics error: $e');
    } finally {
      _isFlushing = false;
    }
  }

  Future<String> _getSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    var sessionId = prefs.getString('session_id');
    if (sessionId == null) {
      sessionId = DateTime.now().millisecondsSinceEpoch.toString();
      prefs.setString('session_id', sessionId);
    }
    return sessionId;
  }

  Future<Map<String, String>> _getDeviceInfo() async {
    // TODO: implement proper device info collection
    return {
      'platform': 'unknown',
      'version': '1.0.0',
    };
  }
}
