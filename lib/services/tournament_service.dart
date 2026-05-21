import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Manages tournament lifecycle: creation, registration, bracket generation,
/// match progression, and prize distribution.
class TournamentService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Create a new tournament
  Future<String> createTournament({
    required String name,
    required int maxPlayers,
    required int entryFee,
    required DateTime startTime,
  }) async {
    final ref = await _db.collection('tournaments').add({
      'name': name,
      'maxPlayers': maxPlayers,
      'entryFee': entryFee,
      'startTime': startTime.toIso8601String(),
      'status': 'registration',
      'players': [],
      'prizePool': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  /// Register a player for a tournament
  Future<Map<String, dynamic>> registerPlayer(String tournamentId, String userId) async {
    final tournRef = _db.collection('tournaments').doc(tournamentId);
    final tournDoc = await tournRef.get();

    if (!tournDoc.exists) {
      return {'success': false, 'error': 'Tournament not found'};
    }

    final data = tournDoc.data()!;
    final players = List<String>.from(data['players'] ?? []);
    final maxPlayers = data['maxPlayers'] as int;
    final entryFee = data['entryFee'] as int;
    final status = data['status'] as String;

    if (status != 'registration') {
      return {'success': false, 'error': 'Registration closed'};
    }

    if (players.contains(userId)) {
      return {'success': false, 'error': 'Already registered'};
    }

    if (players.length >= maxPlayers) {
      return {'success': false, 'error': 'Tournament full'};
    }

    // Deduct entry fee from user
    final userRef = _db.collection('users').doc(userId);
    final userDoc = await userRef.get();
    final userCredits = (userDoc.data()?['credits'] ?? 0) as int;

    if (userCredits < entryFee) {
      return {'success': false, 'error': 'Insufficient credits'};
    }

    // Register player and deduct fee
    await userRef.update({'credits': FieldValue.increment(-entryFee)});
    await tournRef.update({
      'players': FieldValue.arrayUnion([userId]),
      'prizePool': FieldValue.increment(entryFee),
    });

    return {'success': true, 'position': players.length + 1};
  }

  /// Generate bracket when tournament starts
  Future<void> generateBracket(String tournamentId) async {
    final tournRef = _db.collection('tournaments').doc(tournamentId);
    final tournDoc = await tournRef.get();
    final players = List<String>.from(tournDoc.data()?['players'] ?? []);

    // Shuffle for random seeding
    players.shuffle();

    // Create round 1 matches
    final matches = <Map<String, dynamic>>[];
    for (int i = 0; i < players.length; i += 2) {
      if (i + 1 < players.length) {
        matches.add({
          'player1': players[i],
          'player2': players[i + 1],
          'round': 1,
          'status': 'pending',
          'winner': null,
        });
      } else {
        // Bye — player advances automatically
        matches.add({
          'player1': players[i],
          'player2': null,
          'round': 1,
          'status': 'complete',
          'winner': players[i],
        });
      }
    }

    // Store matches
    for (final match in matches) {
      await _db.collection('tournaments').doc(tournamentId)
          .collection('matches').add(match);
    }

    await tournRef.update({'status': 'in_progress', 'currentRound': 1});
  }

  /// Record match result and advance winner
  Future<void> recordMatchResult(String tournamentId, String matchId, String winnerId) async {
    final matchRef = _db.collection('tournaments').doc(tournamentId)
        .collection('matches').doc(matchId);

    await matchRef.update({
      'winner': winnerId,
      'status': 'complete',
      'completedAt': FieldValue.serverTimestamp(),
    });

    // Check if round is complete
    final roundMatches = await _db.collection('tournaments').doc(tournamentId)
        .collection('matches')
        .where('round', isEqualTo: 1)
        .get();

    final allComplete = roundMatches.docs.every((d) => d.data()['status'] == 'complete');

    if (allComplete) {
      await _advanceToNextRound(tournamentId);
    }
  }

  Future<void> _advanceToNextRound(String tournamentId) async {
    final tournRef = _db.collection('tournaments').doc(tournamentId);
    final currentRound = (await tournRef.get()).data()?['currentRound'] as int? ?? 1;

    // Get winners from current round
    final matches = await _db.collection('tournaments').doc(tournamentId)
        .collection('matches')
        .where('round', isEqualTo: currentRound)
        .get();

    final winners = matches.docs
        .map((d) => d.data()['winner'] as String?)
        .where((w) => w != null)
        .cast<String>()
        .toList();

    if (winners.length <= 1) {
      // Tournament complete — distribute prizes
      await _distributePrizes(tournamentId, winners.isNotEmpty ? winners.first : '');
      return;
    }

    // Create next round matches
    for (int i = 0; i < winners.length; i += 2) {
      if (i + 1 < winners.length) {
        await _db.collection('tournaments').doc(tournamentId)
            .collection('matches').add({
          'player1': winners[i],
          'player2': winners[i + 1],
          'round': currentRound + 1,
          'status': 'pending',
          'winner': null,
        });
      }
    }

    await tournRef.update({'currentRound': currentRound + 1});
  }

  Future<void> _distributePrizes(String tournamentId, String winnerId) async {
    final tournDoc = await _db.collection('tournaments').doc(tournamentId).get();
    final prizePool = (tournDoc.data()?['prizePool'] ?? 0) as int;

    // Winner gets 70%, runner-up gets 30%
    final winnerPrize = (prizePool * 0.7).round();

    await _db.collection('users').doc(winnerId).update({
      'credits': FieldValue.increment(winnerPrize),
    });

    await _db.collection('tournaments').doc(tournamentId).update({
      'status': 'complete',
      'winnerId': winnerId,
      'completedAt': FieldValue.serverTimestamp(),
    });
  }
}
