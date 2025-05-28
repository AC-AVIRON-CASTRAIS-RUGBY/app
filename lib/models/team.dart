class Team {
  final int id;
  final String name;
  final String? logo;
  final String ageCategory;
  final int tournamentId;

  Team({
    required this.id,
    required this.name,
    this.logo,
    required this.ageCategory,
    required this.tournamentId,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['Team_Id'],
      name: json['name'],
      logo: json['logo'],
      ageCategory: json['age_category'],
      tournamentId: json['Tournament_Id'],
    );
  }
}