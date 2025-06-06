import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:aviron_castrais_rugby/config/api_config.dart';

class AuthService {
  static String? _refereeName;
  static String? _refereeFirstName;
  static int? _refereeId;

  static String? get refereeName => _refereeName;
  static String? get refereeFirstName => _refereeFirstName;
  static int? get refereeId => _refereeId;
  static bool get isLoggedIn => _refereeId != null;

  Future<void> refereeLogin(String loginUUID, String password) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/auth/referee-login');
    
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'loginUUID': loginUUID,
          'password': password,
        }),
      );

      print(response.body); // Console.log de la réponse

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Stocker les données de l'arbitre
        _refereeName = data['refereeName'];
        _refereeFirstName = data['refereeFirstName'] ?? data['refereeName']?.split(' ').first;
        _refereeId = data['refereeId'];
        
        return;
      } else {
        // Erreur de connexion
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Erreur de connexion');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Erreur de connexion réseau');
    }
  }

  Future<void> logout() async {
    _refereeName = null;
    _refereeFirstName = null;
    _refereeId = null;
  }
}
