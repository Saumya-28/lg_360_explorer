import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ImageService {
  Future<String?> getImageForQuery(String query) async {
    try {
      final uri = Uri.parse(
          'https://en.wikipedia.org/w/api.php?action=query&prop=pageimages&format=json&piprop=original&titles=$query&pithumbsize=1000');
      
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final pages = data['query']['pages'] as Map<String, dynamic>;
        
        if (pages.isNotEmpty) {
           final pageId = pages.keys.first;
           if (pageId != "-1") {
             final page = pages[pageId];
             if (page['original'] != null) {
               return page['original']['source'];
             }
           }
        }
      }
    } catch (e) {
      print('Error fetching image from Wikipedia: $e');
    }
    return null;
  }
}

final imageServiceProvider = Provider<ImageService>((ref) {
  return ImageService();
});
