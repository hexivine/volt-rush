'use client';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:volt_rush/providers/leaderboard_provider.dart';
import 'package:volt_rush/providers/auth_provider.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _medalColor(int index) {
    switch (index) {
      case 0: return const Color(0xFFFFD700);
      case 1: return const Color(0xFFC0C0C0);
      case 2: return const Color(0xFFCD7F32);
      default: return Colors.white54;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = Provider.of<AuthProvider>(context, listen: false).user?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text('Leaderboard', style: GoogleFonts.oswald(fontSize: 24)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFF1A1A1A),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search players...',
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF2A2A2A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white54),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
              onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
            ),
          ),
          Expanded(
            child: _buildLeaderboardContent(currentUserId),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardContent(String? currentUserId) {
    return StreamBuilder<QuerySnapshot>(
      stream: Provider.of<LeaderboardProvider>(context).leaderboardStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Something went wrong', style: GoogleFonts.oswald(color: Colors.red)),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text('No scores yet!', style: GoogleFonts.oswald(color: Colors.white54, fontSize: 20)),
          );
        }

        var docs = snapshot.data!.docs;

        if (_searchQuery.isNotEmpty) {
          return _buildListView(snapshot, currentUserId, docs);
        }

        var topThree = docs.take(3).toList();
        return Column(
          children: [
            _buildPodium(topThree, currentUserId),
            Expanded(
              child: _buildListView(snapshot, currentUserId, docs),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPodium(List<QueryDocumentSnapshot> topThree, String? currentUserId) {
    if (topThree.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (topThree.length > 1)
            _podiumSpot(topThree[1], 2, currentUserId, 90),
          if (topThree.isNotEmpty)
            _podiumSpot(topThree[0], 1, currentUserId, 120),
          if (topThree.length > 2)
            _podiumSpot(topThree[2], 3, currentUserId, 70),
        ],
      ),
    );
  }

  Widget _podiumSpot(QueryDocumentSnapshot doc, int rank, String? currentUserId, double height) {
    var data = doc.data() as Map<String, dynamic>;
    var score = data['score'] ?? 0;
    var userId = data['userId'] ?? 'anonymous';
    var isCurrentUser = doc.id == currentUserId;
    final medals = ['🥇', '🥈', '🥉'];

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        height: height,
        decoration: BoxDecoration(
          color: isCurrentUser ? Colors.amber.withOpacity(0.2) : const Color(0xFF2A2A2A),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          border: isCurrentUser ? Border.all(color: Colors.amber.withOpacity(0.5), width: 1.5) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(medals[rank - 1], style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(
              userId.length > 6 ? '${userId.substring(0, 6)}…' : userId,
              style: GoogleFonts.oswald(
                fontSize: 12,
                color: isCurrentUser ? Colors.amber : Colors.white70,
                fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '$score',
              style: GoogleFonts.oswald(
                fontSize: 16,
                color: isCurrentUser ? Colors.amber : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView(AsyncSnapshot<QuerySnapshot> snapshot, String? currentUserId, List<QueryDocumentSnapshot> docs) {
    if (snapshot.hasError) {
      return Center(
        child: Text('Something went wrong', style: GoogleFonts.oswald(color: Colors.red)),
      );
    }
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
      return Center(
        child: Text('No scores yet!', style: GoogleFonts.oswald(color: Colors.white54, fontSize: 20)),
      );
    }

    var filtered = docs.where((doc) {
      var data = doc.data() as Map<String, dynamic>;
      var userId = data['userId'] ?? 'anonymous';
      if (_searchQuery.isEmpty) return true;
      return userId.toLowerCase().contains(_searchQuery);
    }).toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        var doc = filtered[index];
        var data = doc.data() as Map<String, dynamic>;
        var score = data['score'] ?? 0;
        var userId = data['userId'] ?? 'anonymous';
        var isCurrentUser = doc.id == currentUserId;
        var displayName = userId.length > 8 ? '${userId.substring(0, 8)}...' : userId;
        var rank = docs.indexOf(doc) + 1;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isCurrentUser
                ? Colors.amber.withOpacity(0.15)
                : const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(12),
            border: isCurrentUser
                ? Border.all(color: Colors.amber.withOpacity(0.4))
                : null,
          ),
          child: ListTile(
            leading: SizedBox(
              width: 40,
              child: Center(
                child: index < 3
                    ? Icon(Icons.emoji_events, color: _medalColor(index), size: 28)
                    : Text(
                        '$rank',
                        style: GoogleFonts.oswald(
                          fontSize: 20,
                          color: Colors.white54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            title: Text(
              isCurrentUser ? '$displayName (You)' : displayName,
              style: GoogleFonts.oswald(
                fontSize: 16,
                color: isCurrentUser ? Colors.amber : Colors.white,
                fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            trailing: Text(
              score.toString(),
              style: GoogleFonts.oswald(
                fontSize: 22,
                color: isCurrentUser ? Colors.amber : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}
