import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../../domain/entities/city.dart';
import '../../core/services/lg_service.dart';
import '../../core/services/weather_service.dart';
import '../../core/utils/kml_builder.dart';
import '../providers/lg_connection_provider.dart';


class HeatmapState {
  final bool isLoading;
  final String? error;
  final City? currentCity;
  final WeatherData? weatherData;

  HeatmapState({
    this.isLoading = false,
    this.error,
    this.currentCity,
    this.weatherData,
  });

  HeatmapState copyWith({
    bool? isLoading,
    String? error,
    City? currentCity,
    WeatherData? weatherData,
  }) {
    return HeatmapState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentCity: currentCity ?? this.currentCity,
      weatherData: weatherData ?? this.weatherData,
    );
  }
}

class HeatmapViewModel extends StateNotifier<HeatmapState> {
  final LGService _lgService;
  final WeatherService _weatherService;

  HeatmapViewModel(this._lgService, this._weatherService) : super(HeatmapState());

  final List<City> cities = [
    City(name: 'New York', latitude: 40.7128, longitude: -74.0060, description: 'The City That Never Sleeps', imageUrl: ''),
    City(name: 'London', latitude: 51.5074, longitude: -0.1278, description: 'Capital of England', imageUrl: ''),
    City(name: 'Tokyo', latitude: 35.6762, longitude: 139.6503, description: 'Technological Hub', imageUrl: ''),
    City(name: 'New Delhi', latitude: 28.6139, longitude: 77.2090, description: 'Capital of India', imageUrl: ''),
    City(name: 'Dubai', latitude: 25.2048, longitude: 55.2708, description: 'City of Gold', imageUrl: ''),
  ];

  Future<void> showHeatmap(City city) async {
    state = state.copyWith(isLoading: true, error: null, currentCity: city);

    try {
      // 1. Get Full Weather Data (Temp, AQI, Humidity, Wind)
      final weather = await _weatherService.getWeather(city.latitude, city.longitude);
      state = state.copyWith(weatherData: weather);
      
      final temp = weather.temperature;

      // 2. Determine Color (RRGGBB)
      String colorHex;
      if (temp < 10) {
        colorHex = '0000FF'; // Blue
      } else if (temp < 25) {
        colorHex = '00FF00'; // Green
      } else if (temp < 35) {
        colorHex = 'FFA500'; // Orange
      } else {
        colorHex = 'FF0000'; // Red
      }

      // 3. Generate KML
      final kml = KMLBuilder.createHeatmapGradient(
        latitude: city.latitude,
        longitude: city.longitude,
        radius: 15000, // 15km max radius
        colorHex: colorHex,
        name: '${city.name} Heatmap (${temp}°C)',
      );

      // 4. Send to LG
      
      await _lgService.flyTo(city.latitude, city.longitude, 50000, 0, 0); // High altitude to see heatmap
      
      // Sending heatmap KML to Master so it syncs to all screens
      await _lgService.sendKML(kml); 
      
      // 5. Generate Rich Balloon Content
      String aqiColor = 'green';
      String aqiText = 'Good';
      if (weather.aqi > 50) { aqiColor = 'yellow'; aqiText = 'Moderate'; }
      if (weather.aqi > 100) { aqiColor = 'orange'; aqiText = 'Unhealthy for Sensitive Groups'; }
      if (weather.aqi > 150) { aqiColor = 'red'; aqiText = 'Unhealthy'; }
      if (weather.aqi > 200) { aqiColor = 'purple'; aqiText = 'Very Unhealthy'; }
      if (weather.aqi > 300) { aqiColor = 'maroon'; aqiText = 'Hazardous'; }

      final balloon = KMLBuilder.createBalloon(
        title: '${city.name} Weather Station',
        content: '''
          <div style="font-family: Arial, sans-serif; padding: 20px; min-width: 300px;">
            <h1 style="margin: 0; color: #333;">${city.name}</h1>
            <p style="color: #666; margin-top: 5px;">Real-time Weather & Air Quality</p>
            
            <hr style="border: 0; border-top: 1px solid #eee; margin: 15px 0;">

            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 10px;">
              <span style="font-size: 18px; color: #555;">Temperature:</span>
              <span style="font-size: 24px; font-weight: bold; color: #333;">${weather.temperature}°C</span>
            </div>

            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 10px;">
              <span style="font-size: 18px; color: #555;">Humidity:</span>
              <span style="font-size: 24px; font-weight: bold; color: #333;">${weather.humidity}%</span>
            </div>

            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px;">
              <span style="font-size: 18px; color: #555;">Wind Speed:</span>
              <span style="font-size: 24px; font-weight: bold; color: #333;">${weather.windSpeed} km/h</span>
            </div>

            <div style="background-color: #f5f5f5; padding: 15px; border-radius: 8px; text-align: center;">
              <span style="font-size: 16px; color: #777; display: block; margin-bottom: 5px;">Air Quality Index (US AQI)</span>
              <span style="font-size: 36px; font-weight: bold; color: $aqiColor;">${weather.aqi}</span>
              <span style="font-size: 18px; font-weight: bold; color: $aqiColor; display: block;">$aqiText</span>
            </div>

            <p style="font-size: 12px; color: #999; margin-top: 20px; text-align: right;">Data source: OpenMeteo</p>
          </div>
        ''',
        latitude: city.latitude,
        longitude: city.longitude,
      );
      await _lgService.sendBalloonToRightScreen(balloon);

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> clearHeatmap() async {
    await _lgService.clearKML();
    state = HeatmapState();
  }
  Future<void> showWorldHeatmap() async {
    state = state.copyWith(isLoading: true, error: null, currentCity: null);

    // Global Grid of major cities for World Weather Map
    final worldCities = [
      // North America
      City(name: 'New York', latitude: 40.7128, longitude: -74.0060, description: '', imageUrl: ''),
      City(name: 'Los Angeles', latitude: 34.0522, longitude: -118.2437, description: '', imageUrl: ''),
      City(name: 'Toronto', latitude: 43.6532, longitude: -79.3832, description: '', imageUrl: ''),
      City(name: 'Mexico City', latitude: 19.4326, longitude: -99.1332, description: '', imageUrl: ''),
      
      // South America
      City(name: 'Rio de Janeiro', latitude: -22.9068, longitude: -43.1729, description: '', imageUrl: ''),
      City(name: 'Buenos Aires', latitude: -34.6037, longitude: -58.3816, description: '', imageUrl: ''),
      City(name: 'Lima', latitude: -12.0464, longitude: -77.0428, description: '', imageUrl: ''),
      City(name: 'Bogota', latitude: 4.7110, longitude: -74.0721, description: '', imageUrl: ''),

      // Europe
      City(name: 'London', latitude: 51.5074, longitude: -0.1278, description: 'Capital of England', imageUrl: ''),
      City(name: 'Paris', latitude: 48.8566, longitude: 2.3522, description: '', imageUrl: ''),
      City(name: 'Berlin', latitude: 52.5200, longitude: 13.4050, description: '', imageUrl: ''),
      City(name: 'Moscow', latitude: 55.7558, longitude: 37.6173, description: '', imageUrl: ''),
      City(name: 'Madrid', latitude: 40.4168, longitude: -3.7038, description: '', imageUrl: ''),

      // Africa
      City(name: 'Cairo', latitude: 30.0444, longitude: 31.2357, description: '', imageUrl: ''),
      City(name: 'Lagos', latitude: 6.5244, longitude: 3.3792, description: '', imageUrl: ''),
      City(name: 'Cape Town', latitude: -33.9249, longitude: 18.4241, description: '', imageUrl: ''),
      City(name: 'Nairobi', latitude: -1.2921, longitude: 36.8219, description: '', imageUrl: ''),

      // Asia
      City(name: 'Tokyo', latitude: 35.6762, longitude: 139.6503, description: 'Technological Hub', imageUrl: ''),
      City(name: 'Beijing', latitude: 39.9042, longitude: 116.4074, description: '', imageUrl: ''),
      City(name: 'Mumbai', latitude: 19.0760, longitude: 72.8777, description: '', imageUrl: ''),
      City(name: 'New Delhi', latitude: 28.6139, longitude: 77.2090, description: '', imageUrl: ''),
      City(name: 'Dubai', latitude: 25.2048, longitude: 55.2708, description: '', imageUrl: ''),
      City(name: 'Bangkok', latitude: 13.7563, longitude: 100.5018, description: '', imageUrl: ''),
      City(name: 'Singapore', latitude: 1.3521, longitude: 103.8198, description: '', imageUrl: ''),
      
      // Oceania
      City(name: 'Sydney', latitude: -33.8688, longitude: 151.2093, description: '', imageUrl: ''),
      City(name: 'Melbourne', latitude: -37.8136, longitude: 144.9631, description: '', imageUrl: ''),
      City(name: 'Auckland', latitude: -36.8485, longitude: 174.7633, description: '', imageUrl: ''),
    ];

    try {
      StringBuffer combinedKml = StringBuffer();
      combinedKml.write('''<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
  <Document>
    <name>World Weather Map</name>
''');

      await Future.forEach(worldCities, (city) async {
        final weather = await _weatherService.getWeather(city.latitude, city.longitude);
        final temp = weather.temperature;
        
        // Detailed Color Scale (RRGGBB)
        String colorHex;
        if (temp < -10) {
          colorHex = '800080'; // Purple (Deep Freeze)
        } else if (temp < 0) {
          colorHex = '4B0082'; // Indigo
        } else if (temp < 10) {
          colorHex = '0000FF'; // Blue
        } else if (temp < 20) {
          colorHex = '00FF00'; // Green
        } else if (temp < 30) {
          colorHex = 'FFA500'; // Orange
        } else {
          colorHex = 'FF0000'; // Red - Hot!
        }

        // Reusing logic for fragment generation
        String rr = colorHex.substring(0, 2);
        String gg = colorHex.substring(2, 4);
        String bb = colorHex.substring(4, 6);
        String bbggrr = '$bb$gg$rr';
        
        List<String> opacities = ['55', '44', '33', '22', '11'];
        List<double> radiusFactors = [1.0, 0.8, 0.6, 0.4, 0.2];
        double maxRadius = 800000; // 800km radius for global visibility

        for (int i = 0; i < 5; i++) {
            String styleId = 'heatmap_${city.name}_$i';
            String kmlColor = '${opacities[i]}$bbggrr';
            double currentRadius = maxRadius * radiusFactors[i];

             combinedKml.write('''
    <Style id="$styleId">
      <PolyStyle>
        <color>$kmlColor</color>
        <fill>1</fill>
        <outline>0</outline>
      </PolyStyle>
    </Style>
    <Placemark>
      <name>${city.name}_Layer_$i</name>
      <styleUrl>#$styleId</styleUrl>
      <Polygon>
        <altitudeMode>clampToGround</altitudeMode>
        <outerBoundaryIs>
          <LinearRing>
            <coordinates>
''');
            // Simplified circle generation
            double latScale = 1 / 111320;
            double lonScale = 1 / (40075000 * math.cos(city.latitude * math.pi / 180) / 360);
            
            int steps = 18; // Low poly for global performance
            for (int j = 0; j <= steps; j++) {
              double angle = (2 * math.pi * j) / steps;
              double dx = currentRadius * math.cos(angle);
              double dy = currentRadius * math.sin(angle);
              double pLat = city.latitude + dy * latScale;
              double pLon = city.longitude + dx * lonScale;
              combinedKml.write('$pLon,$pLat,0 ');
            }
            combinedKml.write('''
            </coordinates>
          </LinearRing>
        </outerBoundaryIs>
      </Polygon>
    </Placemark>
''');
        }
      });

      combinedKml.write('''
  </Document>
</kml>''');

      // Fly to a global view (Space view)
      await _lgService.flyTo(0, 20, 20000000, 0, 0); // High altitude over Africa/Europe to see most continents
      
      await _lgService.sendKML(combinedKml.toString());

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final weatherServiceProvider = Provider((ref) => WeatherService());

final heatmapProvider = StateNotifierProvider<HeatmapViewModel, HeatmapState>((ref) {
  final lgService = ref.read(lgServiceProvider);
  final weatherService = ref.read(weatherServiceProvider);
  return HeatmapViewModel(lgService, weatherService);
});
