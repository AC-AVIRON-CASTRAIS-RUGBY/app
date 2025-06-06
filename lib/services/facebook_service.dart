import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:aviron_castrais_rugby/models/facebook_post.dart';

class FacebookService {
  // Utilisation d'un service RSS.app pour récupérer les posts Facebook
  static const String _rssAppUrl = 'https://rss.app/feeds/v1.1/8cQkSliFnip5e1Bt.json';

  Future<List<FacebookPost>> getPosts() async {
    try {
      final response = await http.get(
        Uri.parse(_rssAppUrl),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List? ?? [];
        
        return items.map((item) => FacebookPost(
          id: item['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
          message: item['content_text'] ?? item['title'] ?? '',
          imageUrl: item['image'],
          createdTime: DateTime.parse(item['date_published'] ?? DateTime.now().toIso8601String()),
          permalink: item['url'] ?? 'https://facebook.com/avironcastrais',
          likesCount: 0,
          commentsCount: 0,
        )).toList();
      } else {
        throw Exception('Erreur lors du chargement des posts Facebook: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }
}
