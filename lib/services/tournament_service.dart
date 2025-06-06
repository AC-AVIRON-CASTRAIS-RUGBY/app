// lib/services/tournament_service.dart

import 'package:aviron_castrais_rugby/services/api_service.dart';
import 'package:aviron_castrais_rugby/models/tournament.dart';
import 'package:aviron_castrais_rugby/models/schedule.dart';
import 'package:aviron_castrais_rugby/models/standings.dart';

class TournamentService {
  final ApiService _apiService = ApiService();

  Future<List<Tournament>> getTournaments() async {
    final response = await _apiService.get('tournaments');

    // Vérifier si la réponse est une erreur (sous forme de Map)
    if (response is Map && response.containsKey('error')) {
      throw Exception(response['message'] ?? 'Erreur lors de la récupération des tournois');
    }

    // Gérer le cas où la réponse est une liste directement
    List<dynamic> tournamentsJson;
    if (response is List) {
      tournamentsJson = response;
    } else if (response is Map) {
      // Si la réponse est un Map, chercher le tableau de données
      tournamentsJson = response['data'] ?? [];
    } else {
      throw Exception('Format de réponse inattendu');
    }

    return tournamentsJson.map((json) => Tournament.fromJson(json)).toList();
  }

  Future<Schedule> getSchedule(int tournamentId) async {
    print('Requesting schedule for tournament: $tournamentId'); // Debug log
    final response = await _apiService.get('schedule/tournaments/$tournamentId');

    print('Schedule response type: ${response.runtimeType}'); // Debug log
    print('Schedule response: $response'); // Debug log

    // Vérifier si la réponse est une erreur (sous forme de Map)
    if (response is Map && response.containsKey('error')) {
      throw Exception(response['message'] ?? 'Erreur lors de la récupération du calendrier');
    }

    // Convertir la réponse en Map<String, dynamic>
    Map<String, dynamic> scheduleData;
    if (response is Map) {
      scheduleData = Map<String, dynamic>.from(response);
    } else {
      throw Exception('Format de réponse inattendu pour le calendrier');
    }

    return Schedule.fromJson(scheduleData);
  }

  Future<List<TeamStanding>> getStandings(int tournamentId) async {
    final response = await _apiService.get('pools/tournaments/$tournamentId/standings/all');

    // Vérifier si la réponse est une erreur (sous forme de Map)
    if (response is Map && response.containsKey('error')) {
      throw Exception(response['message'] ?? 'Erreur lors de la récupération du classement');
    }

    // Gérer le cas où la réponse est une liste directement
    List<dynamic> standingsJson;
    if (response is List) {
      standingsJson = response;
    } else if (response is Map) {
      // Si la réponse est un Map, chercher le tableau de données
      standingsJson = response['data'] ?? [];
    } else {
      throw Exception('Format de réponse inattendu');
    }

    final standings = standingsJson.map((json) => TeamStanding.fromJson(json)).toList();
      
    return standings;
  }

  // Ajouter une méthode pour récupérer les détails d'un match spécifique
  Future<Map<String, dynamic>> getMatchDetails(int matchId) async {
    try {
      print('Requesting match details for ID: $matchId'); // Debug log
      final response = await _apiService.get('games/$matchId');
      
      print('Match details response type: ${response.runtimeType}'); // Debug log
      print('Match details response: $response'); // Debug log

      if (response is Map && response.containsKey('error')) {
        throw Exception(response['message'] ?? 'Erreur lors de la récupération du match');
      }

      // Convertir la réponse en Map<String, dynamic>
      if (response is Map) {
        Map<String, dynamic> matchData = Map<String, dynamic>.from(response);
        
        // S'assurer que les scores sont présents et formatés correctement
        if (matchData.containsKey('Team1_Score')) {
          matchData['team1Score'] = matchData['Team1_Score'];
        }
        if (matchData.containsKey('Team2_Score')) {
          matchData['team2Score'] = matchData['Team2_Score'];
        }
        if (matchData.containsKey('is_completed')) {
          matchData['isCompleted'] = matchData['is_completed'] == 1 || matchData['is_completed'] == true;
        }
        
        return matchData;
      } else {
        throw Exception('Format de réponse inattendu pour le match');
      }
    } catch (e) {
      print('Error fetching match details: $e');
      rethrow;
    }
  }

  void dispose() {
    _apiService.dispose();
  }
}