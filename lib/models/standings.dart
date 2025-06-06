class Category {
  final int categoryId;
  final String name;
  final int ageMin;
  final int ageMax;
  final String description;
  final int gameDuration;
  final int tournamentId;

  Category({
    required this.categoryId,
    required this.name,
    required this.ageMin,
    required this.ageMax,
    required this.description,
    required this.gameDuration,
    required this.tournamentId,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      categoryId: json['Category_Id'],
      name: json['name'],
      ageMin: json['age_min'],
      ageMax: json['age_max'],
      description: json['description'],
      gameDuration: json['game_duration'],
      tournamentId: json['Tournament_Id'],
    );
  }
}

class CategoryStandings {
  final int categoryId;
  final String categoryName;
  final int tournamentId;
  final List<TeamStanding> standings;

  CategoryStandings({
    required this.categoryId,
    required this.categoryName,
    required this.tournamentId,
    required this.standings,
  });

  factory CategoryStandings.fromJson(Map<String, dynamic> json) {
    return CategoryStandings(
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
      tournamentId: json['tournamentId'],
      standings: (json['standings'] as List)
          .map((standing) => TeamStanding.fromJson(standing))
          .toList(),
    );
  }
}

class TeamStanding {
  final int teamId;
  final String teamName;
  final String? logo;
  final int matchesPlayed;
  final int wins;
  final int losses;
  final int draws;
  final int points;
  final int goalsFor;
  final int goalsAgainst;
  final int goalDifference;
  final int rank;

  TeamStanding({
    required this.teamId,
    required this.teamName,
    this.logo,
    required this.matchesPlayed,
    required this.wins,
    required this.losses,
    required this.draws,
    required this.points,
    required this.goalsFor,
    required this.goalsAgainst,
    required this.goalDifference,
    required this.rank,
  });

  factory TeamStanding.fromJson(Map<String, dynamic> json) {
    return TeamStanding(
      teamId: json['Team_Id'],
      teamName: json['name'],
      logo: json['logo'],
      matchesPlayed: json['matchesPlayed'],
      wins: json['wins'],
      losses: json['losses'],
      draws: json['draws'],
      points: json['points'],
      goalsFor: json['goalsFor'],
      goalsAgainst: json['goalsAgainst'],
      goalDifference: json['goalDifference'],
      rank: json['rank'],
    );
  }
}
