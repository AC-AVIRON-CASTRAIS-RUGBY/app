// lib/services/tournament_service.dart

import 'package:aviron_castrais_rugby/services/api_service.dart';
import 'package:aviron_castrais_rugby/models/tournament.dart';

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

  void dispose() {
    _apiService.dispose();
  }
}