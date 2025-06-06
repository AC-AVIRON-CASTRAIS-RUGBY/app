class Team {
  final int id;
  final String name;
  final String? logo;
  final int categoryId;
  final int tournamentId;

  Team({
    required this.id,
    required this.name,
    this.logo,
    required this.categoryId,
    required this.tournamentId,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['Team_Id'] ?? json['id'] ?? 0,
      name: json['name'] ?? '',
      logo: json['logo'],
      categoryId: json['Category_Id'] ?? json['categoryId'] ?? 0,
      tournamentId: json['Tournament_Id'] ?? json['tournamentId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Team_Id': id,
      'name': name,
      'logo': logo,
      'Category_Id': categoryId,
      'Tournament_Id': tournamentId,
    };
  }
}