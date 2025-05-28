// lib/services/player_service.dart
import 'package:aviron_castrais_rugby/models/player.dart';
import 'package:aviron_castrais_rugby/services/api_service.dart';

class PlayerService {
  final ApiService _apiService = ApiService();

  Future<List<Player>> getPlayersByTeam(String tournamentId, String teamId) async {
    try {
      final response = await _apiService.get('teams/$tournamentId/$teamId/players');

      if (response is List) {
        return response.map((json) => Player.fromJson(json)).toList();
      } else {
        throw Exception('Format de réponse inattendu');
      }
    } catch (e) {
      throw Exception('Erreur lors du chargement des joueurs: $e');
    }
  }

  void dispose() {
    _apiService.dispose();
  }
}