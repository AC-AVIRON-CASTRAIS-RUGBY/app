// lib/models/player.dart
class Player {
  final String playerId;
  final String name;
  final String position;
  final int? number;
  final String? photo;
  final int? age;
  final String? nationality;

  Player({
    required this.playerId,
    required this.name,
    required this.position,
    this.number,
    this.photo,
    this.age,
    this.nationality,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      playerId: json['playerId'] ?? '',
      name: json['name'] ?? '',
      position: json['position'] ?? '',
      number: json['number'],
      photo: json['photo'],
      age: json['age'],
      nationality: json['nationality'],
    );
  }
}