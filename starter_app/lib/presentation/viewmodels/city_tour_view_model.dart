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

  CityTourState({this.currentCityIndex, this.isPlaying = false});
}

class CityTourViewModel extends StateNotifier<CityTourState> {
  final LGService _lgService;
  Timer? _tourTimer;

  CityTourViewModel(this._lgService) : super(CityTourState());

  Future<void> startTour() async {
    // 0. Clean slate
    stopTour();
    await _lgService.clearKML();
    
    state = CityTourState(currentCityIndex: 0, isPlaying: true);
    
    // 1. Start immediately with the first city
    // No wait for "master KML" anymore
    _playCity(0);
  }

  Future<void> _playCity(int index) async {
    if (!state.isPlaying) return;
    
    final city = _cities[index];
    
    // 1. Fly to City immediately (User feedback: INSTANT)
    // Duration: ~4 seconds for the rig to fly there
    await _lgService.flyTo(city.latitude, city.longitude, 5000, 60, 0);

    // 2. Show Info on Rightmost Screen
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

    // 3. Prepare unique Orbit Tour (Background upload)
    // Use unique filename with timestamp to prevent caching issues
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final tourName = 'Tour_${city.name.replaceAll(" ", "")}_$timestamp';
    final kmlFileName = 'tour_$timestamp.kml';

    final tourKml = KMLBuilder.createCityTour(
      tourName: tourName,
      latitude: city.latitude,
      longitude: city.longitude,
      orbitDuration: 5.0, // Requested 5 seconds
    );
    
    // Upload while flying
    await _lgService.sendKML(tourKml, fileName: kmlFileName);
    
    // 4. Wait for flight to finish + KML load buffer
    // Fly starts at T=0. We waited for the command to send, but the rig is flying now.
    // Let's give it 5 seconds total (4s flight + 1s buffer)
    await Future.delayed(const Duration(seconds: 5));

    if (!state.isPlaying || state.currentCityIndex != index) return;

    // 5. Start Orbit
    await _lgService.startTour(tourName);
    
    // 6. Wait for Orbit (5s) + Post-Orbit Wait (2s) = 7s
    // Total wait before next city: 7 seconds
    _tourTimer = Timer(const Duration(seconds: 7), () {
        if (!state.isPlaying) return;
        
        int nextIndex = state.currentCityIndex! + 1;
        if (nextIndex >= _cities.length) {
          nextIndex = 0;
        }
        
        state = CityTourState(currentCityIndex: nextIndex, isPlaying: true);
        _playCity(nextIndex);
    });
  }

  void stopTour() {
    _tourTimer?.cancel();
    _lgService.stopTour();
    state = CityTourState(currentCityIndex: null, isPlaying: false);
    _lgService.cleanSlaves();
    _lgService.clearKML();
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
