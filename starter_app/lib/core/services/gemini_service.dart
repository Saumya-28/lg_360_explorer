import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/city.dart';
import '../providers/shared_preferences_provider.dart';
import 'dart:convert';
import 'image_service.dart';

class GeminiService {
  late final GenerativeModel _model;
  final ImageService _imageService;

  GeminiService(this._imageService, this._prefs);

  final SharedPreferences _prefs;

  Future<void> _initModel() async {
    final apiKey = _prefs.getString('gemini_api_key');
    if (apiKey == null || apiKey.isEmpty) {
      print('GeminiService: No API key found in settings.');
      return;
    }
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
    );
  }

  Future<List<City>> getPlaces(String query) async {
    await _initModel();
    if (!(_prefs.containsKey('gemini_api_key')) || _prefs.getString('gemini_api_key')!.isEmpty) {
       throw Exception('API Key not found. Please set it in Settings.');
    }
    
    print('GeminiService: getPlaces called with query: $query');
    final prompt = '''
    I need you to act as a travel guide API. 
    The user will ask for places (e.g., "$query").
    
    You must return a JSON object with a key "places" which is a list.
    Each item in the list should have:
    - "name": The name of the place
    - "latitude": The latitude (double)
    - "longitude": The longitude (double)
    - "description": A short, interesting description (max 2 sentences)
    - "imageUrl": A URL to a high-quality public image of the place (Wikipedia or similar stable URL).

    Return ONLY the raw JSON. Do not include markdown formatting like ```json ... ```.
    ''';

    try {
      final content = [Content.text(prompt)];
      print('GeminiService: Sending request to Gemini...');
      final response = await _model.generateContent(content);
      print('GeminiService: Received response from Gemini');

      final text = response.text;
      if (text == null) {
        print('GeminiService: Response text is null');
        throw Exception('No response from Gemini');
      }

      print('GeminiService: Raw response text: $text');

      // Clean up markdown if Gemini adds it despite instructions
      String jsonString = text.replaceAll('```json', '').replaceAll('```', '').trim();
      
      final Map<String, dynamic> data = json.decode(jsonString);
      final List<dynamic> placesJson = data['places'];

      final List<City> cities = [];

      for (var place in placesJson) {
        String imageUrl = place['imageUrl'] ?? '';
        final name = place['name'];

        // Try to get a better image from Wikipedia
        print('GeminiService: Fetching image for $name from Wikipedia...');
        final wikiImage = await _imageService.getImageForQuery(name);
        if (wikiImage != null) {
          print('GeminiService: Found Wikipedia image for $name: $wikiImage');
          imageUrl = wikiImage;
        } else {
          print('GeminiService: No Wikipedia image found for $name');
        }

        cities.add(City(
          name: name,
          latitude: (place['latitude'] as num).toDouble(),
          longitude: (place['longitude'] as num).toDouble(),
          description: place['description'],
          imageUrl: imageUrl,
        ));
      }

      print('GeminiService: Successfully parsed ${cities.length} cities');
      return cities;
    } catch (e) {
      print('GeminiService: Error in getPlaces: $e');
      throw Exception('Failed to fetch recommendations: $e');
    }
  }
}

final geminiServiceProvider = Provider<GeminiService>((ref) {
  final imageService = ref.read(imageServiceProvider);
  final prefs = ref.read(sharedPreferencesProvider);
  return GeminiService(imageService, prefs);
});
