import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:aviron_castrais_rugby/models/category.dart';
import 'package:aviron_castrais_rugby/config/api_config.dart';

class CategoryService {
  Future<List<Category>> getCategoriesByTournament(int tournamentId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/categories/tournaments/$tournamentId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Category.fromJson(json)).toList();
      } else {
        throw Exception('Erreur lors du chargement des catégories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  Future<Category> getCategoryById(int tournamentId, int categoryId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/categories/tournaments/$tournamentId/$categoryId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return Category.fromJson(jsonData);
      } else {
        throw Exception('Erreur lors du chargement de la catégorie: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  void dispose() {
    // Cleanup si nécessaire
  }
}
