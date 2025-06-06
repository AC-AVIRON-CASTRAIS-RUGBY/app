class TeamStanding {
  final int rank;
  final String teamName;
  final int matchesPlayed;
  final int wins;
  final int draws;
  final int losses;
  final int points;
  final int pointsFor;
  final int pointsAgainst;
  final int pointsDifference;

  TeamStanding({
    required this.rank,
    required this.teamName,
    required this.matchesPlayed,
    required this.wins,
    required this.draws,
    required this.losses,
    required this.points,
    required this.pointsFor,
    required this.pointsAgainst,
    required this.pointsDifference,
  });

  factory TeamStanding.fromJson(Map<String, dynamic> json) {
    return TeamStanding(
      rank: json['rank'] ?? 0,
      teamName: json['name'] ?? '',
      matchesPlayed: json['matchesPlayed'] ?? 0,
      wins: json['wins'] ?? 0,
      draws: json['draws'] ?? 0,
      losses: json['losses'] ?? 0,
      points: json['points'] ?? 0,
      pointsFor: json['pointsFor'] ?? 0,
      pointsAgainst: json['pointsAgainst'] ?? 0,
      pointsDifference: json['pointsDifference'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rank': rank,
      'teamName': teamName,
      'matchesPlayed': matchesPlayed,
      'wins': wins,
      'draws': draws,
      'losses': losses,
      'points': points,
      'pointsFor': pointsFor,
      'pointsAgainst': pointsAgainst,
      'pointsDifference': pointsDifference,
    };
  }
}
