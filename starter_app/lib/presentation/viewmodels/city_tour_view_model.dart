import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/city.dart';
import '../../core/services/lg_service.dart';
import '../../core/utils/kml_builder.dart';
import '../providers/lg_connection_provider.dart';

// Static list of cities
const List<City> _cities = [
  City(
    name: 'New York City',
    latitude: 40.7128,
    longitude: -74.0060,
    description: 'New York City comprises 5 boroughs sitting where the Hudson River meets the Atlantic Ocean. At its core is Manhattan, a densely populated borough that’s among the world’s major commercial, financial and cultural centers.',
    imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7a/View_of_Empire_State_Building_from_Rockefeller_Center_New_York_City_dllu_%28cropped%29.jpg/800px-View_of_Empire_State_Building_from_Rockefeller_Center_New_York_City_dllu_%28cropped%29.jpg',
  ),
  City(
    name: 'Tokyo',
    latitude: 35.6762,
    longitude: 139.6503,
    description: 'Tokyo, Japan’s busy capital, mixes the ultramodern and the traditional, from neon-lit skyscrapers to historic temples.',
    imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b2/Skyscrapers_of_Shinjuku_2009_January.jpg/800px-Skyscrapers_of_Shinjuku_2009_January.jpg',
  ),
  City(
    name: 'Paris',
    latitude: 48.8584,
    longitude: 2.2945,
    description: 'Paris, France\'s capital, is a major European city and a global center for art, fashion, gastronomy and culture.',
    imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4b/La_Tour_Eiffel_vue_de_la_Tour_Saint-Jacques%2C_Paris_ao%C3%BBt_2014_%282%29.jpg/800px-La_Tour_Eiffel_vue_de_la_Tour_Saint-Jacques%2C_Paris_ao%C3%BBt_2014_%282%29.jpg',
  ),
  City(
    name: 'Sydney',
    latitude: -33.8688,
    longitude: 151.2093,
    description: 'Sydney, capital of New South Wales and one of Australia\'s largest cities, is best known for its harbourfront Sydney Opera House, with a distinctive sail-like design.',
    imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7c/Sydney_Opera_House_-_Dec_2008.jpg/800px-Sydney_Opera_House_-_Dec_2008.jpg',
  ),
  City(
    name: 'Rio de Janeiro',
    latitude: -22.9068,
    longitude: -43.1729,
    description: 'Rio de Janeiro is a huge seaside city in Brazil, famous for its Copacabana and Ipanema beaches, 38m Christ the Redeemer statue atop Mount Corcovado and for Sugarloaf Mountain.',
    imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/98/Christ_the_Redeemer_-_Cristo_Redentor.jpg/800px-Christ_the_Redeemer_-_Cristo_Redentor.jpg',
  ),
];

// State to track current city index and if tour is running
class CityTourState {
  final int? currentCityIndex;
  final bool isPlaying;
  final int totalCities;

  CityTourState({
    this.currentCityIndex, 
    this.isPlaying = false,
    this.totalCities = 0,
  });
}

class CityTourViewModel extends StateNotifier<CityTourState> {
  final LGService _lgService;
  Timer? _tourTimer;
  List<City> _currentTourCities = _cities; // Default to static list

  CityTourViewModel(this._lgService) : super(CityTourState());

  Future<void> startTour({List<City>? customCities}) async {
    // 0. Clean slate
    stopTour();
    await _lgService.clearKML();

    // Use custom cities if provided, otherwise default
    if (customCities != null && customCities.isNotEmpty) {
      _currentTourCities = customCities;
    } else {
      _currentTourCities = _cities;
    }
    
    state = CityTourState(
      currentCityIndex: 0, 
      isPlaying: true,
      totalCities: _currentTourCities.length,
    );
    
    // 1. Start immediately with the first city
    _playCity(0);
  }

  Future<void> _playCity(int index) async {
    if (!state.isPlaying) return;
    
    if (index >= _currentTourCities.length) {
      // Loop back to start
      index = 0;
    }
    
    final city = _currentTourCities[index];
    
    // 1. Fly to City Overview (High Altitude: 10000m)
    await _lgService.flyTo(city.latitude, city.longitude, 10000, 60, 0);
    
    // Wait for arrival at overview
    await Future.delayed(const Duration(seconds: 5));

    if (!state.isPlaying || state.currentCityIndex != index) return;

    // 2. Zoom In (Low Altitude: 1000m)
    await _lgService.flyTo(city.latitude, city.longitude, 1000, 60, 0);
    
    // 3. Show Info on Rightmost Screen (during zoom)
    final balloonKml = KMLBuilder.createBalloon(
      title: city.name,
      content: '''
        <div style="font-family: Google Sans, sans-serif; width: 400px;">
          <h1>${city.name}</h1>
          <img src="${city.imageUrl}" width="400" />
          <p>${city.description}</p>
        </div>
      ''',
      longitude: city.longitude,
      latitude: city.latitude,
    );
    await _lgService.sendBalloonToRightScreen(balloonKml);

    // Wait for zoom to complete
    await Future.delayed(const Duration(seconds: 4));

    if (!state.isPlaying || state.currentCityIndex != index) return;

    // 4. Prepare unique Orbit Tour (Slow speed: 45s duration)
    // The tour will be generated at the zoomed-in range (1000m)
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final tourName = 'Tour_${city.name.replaceAll(" ", "")}_$timestamp';
    final kmlFileName = 'tour_$timestamp.kml';

    final tourKml = KMLBuilder.createCityTour(
      tourName: tourName,
      latitude: city.latitude,
      longitude: city.longitude,
      range: 1000, // Explicitly match the zoom level
      orbitDuration: 45.0, // Slower orbit speed
    );
    
    await _lgService.sendKML(tourKml, fileName: kmlFileName);
    
    // Allow KML to load
    await Future.delayed(const Duration(seconds: 2));

    if (!state.isPlaying || state.currentCityIndex != index) return;

    // 5. Start Orbit
    await _lgService.startTour(tourName);
    
    // 6. Wait for 15 seconds of orbiting, then move to next
    _tourTimer = Timer(const Duration(seconds: 15), () {
        if (!state.isPlaying) return;
        
        int nextIndex = index + 1;
        state = CityTourState(
          currentCityIndex: nextIndex, 
          isPlaying: true,
          totalCities: _currentTourCities.length,
        );
        _playCity(nextIndex);
    });
  }

  void stopTour() {
    _tourTimer?.cancel();
    _lgService.stopTour();
    state = CityTourState(currentCityIndex: null, isPlaying: false);
    _lgService.cleanSlaves();
    _lgService.clearKML();
    _currentTourCities = _cities; // Reset to default
  }
  
  @override
  void dispose() {
    _tourTimer?.cancel();
    super.dispose();
  }
}

final cityTourProvider = StateNotifierProvider<CityTourViewModel, CityTourState>((ref) {
  return CityTourViewModel(ref.read(lgServiceProvider));
});
