class Player {
  final int id;
  final String first_name;
  final String last_name;
  final int? number;
  final String position;
  final int? teamId;
  final bool present;

  Player({
    required this.id,
    required this.first_name,
    required this.last_name,
    this.number,
    this.position = 'Position non définie',
    this.teamId,
    this.present = true,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['Player_Id'] as int,
      first_name: json['first_name'] as String? ?? '',
      last_name: json['last_name'] as String? ?? '',
      number: json['number'] as int?,
      position: json['position'] as String? ?? 'Non défini',
      teamId: json['Team_Id'] as int?,
      present: json['present'] == 1 || json['present'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Player_Id': id,
      'first_name': first_name,
      'last_name': last_name,
      'number': number,
      'position': position,
      'Team_Id': teamId,
      'present': present,
    };
  }
}