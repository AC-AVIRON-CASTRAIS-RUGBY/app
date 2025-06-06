import 'package:aviron_castrais_rugby/models/team.dart';
import 'package:aviron_castrais_rugby/services/api_service.dart';

class TeamService {
  final ApiService _apiService = ApiService();

  Future<List<Team>> getTeamsByTournament(int tournamentId) async {
    try {
      final response = await _apiService.get('teams/tournaments/$tournamentId');

      // Vérifier si la réponse est une erreur (sous forme de Map)
      if (response is Map && response.containsKey('error')) {
        throw Exception(response['message'] ?? 'Erreur lors de la récupération des équipes');
      }

      // Gérer le cas où la réponse est une liste directement
      List<dynamic> teamsJson;
      if (response is List) {
        teamsJson = response;
      } else if (response is Map) {
        // Si la réponse est un Map, chercher le tableau de données
        teamsJson = response['data'] ?? [];
      } else {
        throw Exception('Format de réponse inattendu');
      }

      return teamsJson.map((json) => Team.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erreur lors du chargement des équipes: $e');
    }
  }

  void dispose() {
    _apiService.dispose();
  }
}