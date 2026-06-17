import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:volt_rush/services/profile_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = ProfileService();
  Map<String, dynamic>? _profile;
  Map<String, int> _stats = {'played': 0, 'banked': 0, 'busted': 0};
  int _rank = -1;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final profile = await _profileService.getProfile();
      final stats = await _profileService.getWinStats(_profileService.currentUserId);
      final rank = await _profileService.getUserRank(_profileService.currentUserId);

      if (mounted) {
        setState(() {
          _profile = profile;
          _stats = stats;
          _rank = rank;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final displayName = _profile?['displayName'] ?? 'Player';
    final played = _stats['played']!;
    final banked = _stats['banked']!;
    final busted = _stats['busted']!;
    final winRate = played > 0 ? (banked / played * 100).round() : 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: GoogleFonts.oswald()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 48,
              child: Text(
                displayName[0].toUpperCase(),
                style: const TextStyle(fontSize: 36),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              displayName,
              style: GoogleFonts.oswald(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            if (_rank > 0) ...[
              const SizedBox(height: 8),
              Text(
                'Rank #$rank',
                style: GoogleFonts.oswald(fontSize: 18, color: Colors.amber),
              ),
            ],
            const SizedBox(height: 32),
            _buildStatGrid(played, banked, busted, winRate),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showEditDialog(context),
              icon: const Icon(Icons.edit),
              label: const Text('Edit Profile'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatGrid(int played, int banked, int busted, int winRate) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _statCard('Games Played', '$played', Icons.sports_esports),
        _statCard('Win Rate', '$winRate%', Icons.trending_up),
        _statCard('Banked', '$banked', Icons.savings),
        _statCard('Busted', '$busted', Icons.close),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: Colors.amber),
            const SizedBox(height: 8),
            Text(value, style: GoogleFonts.oswald(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final controller = TextEditingController(text: _profile?['displayName'] ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Profile'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Display Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _profileService.updateProfile(displayName: controller.text);
              if (ctx.mounted) Navigator.pop(ctx);
              _loadData();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
