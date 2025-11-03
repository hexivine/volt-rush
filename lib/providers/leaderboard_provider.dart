import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:volt_rush/services/leaderboard_service.dart';

class LeaderboardProvider with ChangeNotifier {
  final LeaderboardService _leaderboardService = LeaderboardService();

  Stream<QuerySnapshot> get leaderboardStream =>
      _leaderboardService.getLeaderboard();
}
