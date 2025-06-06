class Category {
  final int categoryId;
  final String name;
  final int? gameDuration;
  final int tournamentId;

  Category({
    required this.categoryId,
    required this.name,
    this.gameDuration,
    required this.tournamentId,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      categoryId: json['Category_Id'] ?? json['categoryId'] ?? 0,
      name: json['name'] ?? '',
      gameDuration: json['game_duration'] ?? json['gameDuration'],
      tournamentId: json['Tournament_Id'] ?? json['tournamentId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Category_Id': categoryId,
      'name': name,
      'game_duration': gameDuration,
      'Tournament_Id': tournamentId,
    };
  }
}
