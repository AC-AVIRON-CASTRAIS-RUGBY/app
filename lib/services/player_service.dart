// lib/services/player_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:aviron_castrais_rugby/models/player.dart';
import 'package:aviron_castrais_rugby/config/api_config.dart';

class PlayerService {
  Future<List<Player>> getPlayersByTeam(int tournamentId, int teamId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/teams/tournaments/$tournamentId/$teamId/players'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final dynamic jsonData = json.decode(response.body);
        
        if (jsonData is List) {
          return jsonData.map((json) => Player.fromJson(json)).toList();
        } else {
          throw Exception('Format de réponse inattendu: la réponse n\'est pas une liste');
        }
      } else if (response.statusCode == 404) {
        // Équipe non trouvée, retourner une liste vide
        return [];
      } else {
        throw Exception('Erreur lors du chargement des joueurs: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('Format de réponse inattendu')) {
        rethrow;
      }
      throw Exception('Erreur de connexion: $e');
    }
  }

  void dispose() {
    // Cleanup si nécessaire
  }
}