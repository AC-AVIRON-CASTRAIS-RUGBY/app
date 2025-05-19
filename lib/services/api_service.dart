import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiService {
  final http.Client _client = http.Client();

  // GET request
  Future<dynamic> get(String endpoint) async {
    try {
      //Console.log de l'url
      print('GET request: ${ApiConfig.baseUrl}/$endpoint');
      final response = await _client
          .get(Uri.parse('${ApiConfig.baseUrl}/$endpoint'))
          .timeout(Duration(seconds: ApiConfig.timeoutDuration));

      return _processResponse(response);
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  // POST request
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _client
          .post(
        Uri.parse('${ApiConfig.baseUrl}/$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      )
          .timeout(Duration(seconds: ApiConfig.timeoutDuration));

      return _processResponse(response);
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  // PUT request
  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _client
          .put(
        Uri.parse('${ApiConfig.baseUrl}/$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      )
          .timeout(Duration(seconds: ApiConfig.timeoutDuration));

      return _processResponse(response);
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  // DELETE request
  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final response = await _client
          .delete(Uri.parse('${ApiConfig.baseUrl}/$endpoint'))
          .timeout(Duration(seconds: ApiConfig.timeoutDuration));

      return _processResponse(response);
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  // Traitement de la réponse
  dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Succès - retourne un Map ou une List selon le contenu
      var decodedResponse = json.decode(response.body);
      return decodedResponse;
    } else {
      // Erreur - toujours sous forme de Map
      return {
        'error': 'Erreur ${response.statusCode}',
        'message': response.body,
      };
    }
  }

  // Fermeture du client
  void dispose() {
    _client.close();
  }
}