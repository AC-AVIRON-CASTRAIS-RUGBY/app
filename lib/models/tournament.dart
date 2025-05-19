class Tournament {
  final int tournamentId;
  final String name;
  final String description;
  final String image;
  final String startDate;
  final String location;
  final int gameDuration;
  final int breakTime;

  Tournament({
    required this.tournamentId,
    required this.name,
    required this.description,
    required this.image,
    required this.startDate,
    required this.location,
    required this.gameDuration,
    required this.breakTime,
  });

  factory Tournament.fromJson(Map<String, dynamic> json) {
    return Tournament(
      tournamentId: json['Tournament_Id'],
      name: json['name'],
      description: json['description'],
      image: json['image'],
      startDate: json['start_date'],
      location: json['location'],
      gameDuration: json['game_duration'],
      breakTime: json['break_time'],
    );
  }
}