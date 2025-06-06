import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:aviron_castrais_rugby/config/api_config.dart';

class RefereeService {
  Future<List<RefereeGame>> getRefereeGames(int refereeId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/referees/$refereeId/games');
    
    try {
      print('Requesting URL: $url'); // Debug log
      
      final response = await http.get(url);
      
      print('Response status: ${response.statusCode}'); // Debug log
      print('Response body: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        List<RefereeGame> games = [];
        
        for (var json in data) {
          final game = RefereeGame.fromJson(json);
          
          try {
            print('Fetching team 1 ID: ${game.team1Id}'); // Debug log
            final team1 = await getTeamDetails(json['Tournament_Id'], game.team1Id);
            print('Team 1 fetched successfully: ${team1.name}'); // Debug log
            
            print('Fetching team 2 ID: ${game.team2Id}'); // Debug log
            final team2 = await getTeamDetails(json['Tournament_Id'], game.team2Id);
            print('Team 2 fetched successfully: ${team2.name}'); // Debug log

            print('Team 1: ${team1.name}, Team 2: ${team2.name}'); // Debug log
            
            games.add(RefereeGame(
              gameId: game.gameId,
              startTime: game.startTime,
              team1Id: game.team1Id,
              team2Id: game.team2Id,
              team1Name: team1.name,
              team2Name: team2.name,
              team1Score: game.team1Score,
              team2Score: game.team2Score,
              isCompleted: game.isCompleted,
              refereeId: game.refereeId,
              poolId: game.poolId,
              fieldId: game.fieldId,
              ageCategory: team1.ageCategory, // Utiliser la catégorie de l'équipe 1
            ));
          } catch (e) {
            // Si erreur récupération équipes, utiliser les IDs
            print('Error fetching team details: $e'); // Debug log
            
            // Essayer de récupérer au moins une équipe
            String? team1Name;
            String? team2Name;
            String? ageCategory;
            
            try {
              final team1 = await getTeamDetails(json['Tournament_Id'], game.team1Id);
              team1Name = team1.name;
              ageCategory = team1.ageCategory;
            } catch (e1) {
              print('Failed to fetch team 1: $e1');
            }
            
            try {
              final team2 = await getTeamDetails(json['Tournament_Id'], game.team2Id);
              team2Name = team2.name;
              if (ageCategory == null) ageCategory = team2.ageCategory;
            } catch (e2) {
              print('Failed to fetch team 2: $e2');
            }
            
            games.add(RefereeGame(
              gameId: game.gameId,
              startTime: game.startTime,
              team1Id: game.team1Id,
              team2Id: game.team2Id,
              team1Name: team1Name,
              team2Name: team2Name,
              team1Score: game.team1Score,
              team2Score: game.team2Score,
              isCompleted: game.isCompleted,
              refereeId: game.refereeId,
              poolId: game.poolId,
              fieldId: game.fieldId,
              ageCategory: ageCategory,
            ));
          }
        }
        
        return games;
      } else if (response.statusCode == 404) {
        throw Exception('Aucun match trouvé pour cet arbitre');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Erreur serveur (${response.statusCode})');
      }
    } on FormatException {
      throw Exception('Erreur de format de données');
    } on http.ClientException {
      throw Exception('Erreur de connexion réseau - Vérifiez votre connexion internet');
    } catch (e) {
      print('Error details: $e'); // Debug log
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Erreur inconnue: $e');
    }
  }

  Future<TeamDetails> getTeamDetails(int tournamentId, int teamId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/teams/$tournamentId/teams/$teamId');
    
    try {
      print('Requesting team URL: $url'); // Debug log
      
      final response = await http.get(url);
      
      print('Team response status: ${response.statusCode}'); // Debug log
      print('Team response body: ${response.body}'); // Debug log
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return TeamDetails.fromJson(data);
      } else {
        throw Exception('Équipe non trouvée (${response.statusCode})');
      }
    } catch (e) {
      print('Team fetch error: $e'); // Debug log
      throw Exception('Erreur lors de la récupération de l\'équipe: $e');
    }
  }

  Future<void> updateMatch(int gameId, {
    required int team1Score,
    required int team2Score,
    required bool isCompleted,
    required DateTime startTime,
    required int team1Id,
    required int team2Id,
    required int refereeId,
    required int poolId,
    int? fieldId,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/games/$gameId');
    
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'start_time': startTime.toIso8601String(),
          'Team1_Id': team1Id,
          'Team2_Id': team2Id,
          'Team1_Score': team1Score,
          'Team2_Score': team2Score,
          'is_completed': isCompleted,
          'Referee_Id': refereeId,
          'Pool_Id': poolId,
          'Field_Id': fieldId,
        }),
      );

      print('Update response status: ${response.statusCode}');
      print('Update response body: ${response.body}');

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Erreur lors de la mise à jour');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Erreur de connexion réseau');
    }
  }
}

class TeamDetails {
  final int teamId;
  final String name;
  final String? logo;
  final String ageCategory;
  final int tournamentId;
  final int? poolId;

  TeamDetails({
    required this.teamId,
    required this.name,
    this.logo,
    required this.ageCategory,
    required this.tournamentId,
    this.poolId,
  });

  factory TeamDetails.fromJson(Map<String, dynamic> json) {
    return TeamDetails(
      teamId: json['Team_Id'],
      name: json['name'],
      logo: json['logo'],
      ageCategory: json['age_category'],
      tournamentId: json['Tournament_Id'],
      poolId: json['Pool_Id'],
    );
  }
}

class RefereeGame {
  final int gameId;
  final DateTime startTime;
  final int team1Id;
  final int team2Id;
  final String? team1Name;
  final String? team2Name;
  final int team1Score;
  final int team2Score;
  final bool isCompleted;
  final int refereeId;
  final int poolId;
  final int? fieldId;
  final String? ageCategory;

  RefereeGame({
    required this.gameId,
    required this.startTime,
    required this.team1Id,
    required this.team2Id,
    this.team1Name,
    this.team2Name,
    required this.team1Score,
    required this.team2Score,
    required this.isCompleted,
    required this.refereeId,
    required this.poolId,
    this.fieldId,
    this.ageCategory,
  });

  factory RefereeGame.fromJson(Map<String, dynamic> json) {
    return RefereeGame(
      gameId: json['Game_Id'],
      startTime: DateTime.parse(json['start_time']),
      team1Id: json['Team1_Id'],
      team2Id: json['Team2_Id'],
      team1Score: json['Team1_Score'],
      team2Score: json['Team2_Score'],
      isCompleted: json['is_completed'] == 1,
      refereeId: json['Referee_Id'],
      poolId: json['Pool_Id'],
      fieldId: json['Field_Id'],
    );
  }
}
