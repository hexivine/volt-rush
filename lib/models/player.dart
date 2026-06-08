/// Player model with stats and preferences.
class Player {
  final String id;
  final String displayName;
  final String email;
  final int rating;
  final int gamesPlayed;
  final int highScore;
  final DateTime createdAt;

  const Player({
    required this.id,
    required this.displayName,
    required this.email,
    required this.rating,
    this.gamesPlayed = 0,
    this.highScore = 0,
    required this.createdAt,
  });

  factory Player.fromMap(String id, Map<String, dynamic> map) {
    return Player(
      id: id,
      displayName: map['displayName'] ?? 'Anonymous',
      email: map['email'] ?? '',
      rating: map['rating'] ?? 1000,
      gamesPlayed: map['gamesPlayed'] ?? 0,
      highScore: map['highScore'] ?? 0,
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() => {
    'displayName': displayName,
    'email': email,
    'rating': rating,
    'gamesPlayed': gamesPlayed,
    'highScore': highScore,
    'createdAt': createdAt.toIso8601String(),
  };

  Player copyWith({String? displayName, int? rating, int? gamesPlayed, int? highScore}) {
    return Player(
      id: id,
      displayName: displayName ?? this.displayName,
      email: email,
      rating: rating ?? this.rating,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      highScore: highScore ?? this.highScore,
      createdAt: createdAt,
    );
  }
}
