import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:aviron_castrais_rugby/config/api_config.dart';

class RefereeService {
  Future<List<RefereeGame>> getRefereeGames(int refereeId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/referees/$refereeId/games');
    
    try {
      print('Requesting URL: $url');
      
      final response = await http.get(url);
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        List<RefereeGame> games = [];
        
        for (var json in data) {
          games.add(RefereeGame.fromJson(json));
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
      print('Error details: $e');
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Erreur inconnue: $e');
    }
  }

  Future<void> updateMatch(int gameId, {
    required int team1Score,
    required int team2Score,
    required bool isCompleted,
    DateTime? startTime,
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
          'start_time': startTime?.toIso8601String(),
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

class RefereeGame {
  final int gameId;
  final DateTime? startTime;
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
    this.startTime,
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
      startTime: json['start_time'] != null ? DateTime.parse(json['start_time']) : null,
      team1Id: json['Team1_Id'],
      team2Id: json['Team2_Id'],
      team1Name: json['team1_name'],
      team2Name: json['team2_name'],
      team1Score: json['Team1_Score'],
      team2Score: json['Team2_Score'],
      isCompleted: json['is_completed'] == 1,
      refereeId: json['Referee_Id'],
      poolId: json['Pool_Id'],
      fieldId: json['Field_Id'],
      ageCategory: json['category_name'],
    );
  }
}
