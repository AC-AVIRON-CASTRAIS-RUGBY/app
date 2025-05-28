class Schedule {
  final String tournamentId;
  final String tournamentName;
  final Map<String, List<Game>> schedule;

  Schedule({
    required this.tournamentId,
    required this.tournamentName,
    required this.schedule,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    Map<String, List<Game>> scheduleMap = {};
    
    if (json['schedule'] != null) {
      (json['schedule'] as Map<String, dynamic>).forEach((poolName, games) {
        scheduleMap[poolName] = (games as List)
            .map((game) => Game.fromJson(game))
            .toList();
      });
    }

    return Schedule(
      tournamentId: json['tournamentId'].toString(),
      tournamentName: json['tournamentName'],
      schedule: scheduleMap,
    );
  }
}

class Game {
  final int gameId;
  final String startTime;
  final TeamScore team1;
  final TeamScore team2;
  final String referee;
  final String? field;
  final bool isCompleted;

  Game({
    required this.gameId,
    required this.startTime,
    required this.team1,
    required this.team2,
    required this.referee,
    this.field,
    required this.isCompleted,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      gameId: json['gameId'],
      startTime: json['startTime'],
      team1: TeamScore.fromJson(json['team1']),
      team2: TeamScore.fromJson(json['team2']),
      referee: json['referee'],
      field: json['field'],
      isCompleted: json['isCompleted'],
    );
  }
}

class TeamScore {
  final int id;
  final String name;
  final int score;

  TeamScore({
    required this.id,
    required this.name,
    required this.score,
  });

  factory TeamScore.fromJson(Map<String, dynamic> json) {
    return TeamScore(
      id: json['id'],
      name: json['name'],
      score: json['score'],
    );
  }
}
