import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherData {
  final double temperature;
  final int aqi;
  final double humidity;
  final double windSpeed;

  WeatherData({
    required this.temperature,
    required this.aqi,
    required this.humidity,
    required this.windSpeed,
  });
}

class WeatherService {
  static const String _weatherUrl = 'https://api.open-meteo.com/v1/forecast';
  static const String _aqiUrl = 'https://air-quality-api.open-meteo.com/v1/air-quality';

  Future<WeatherData> getWeather(double latitude, double longitude) async {
    try {
      // 1. Fetch Weather (Temp, Humidity, Wind)
      final weatherUri = Uri.parse(
          '$_weatherUrl?latitude=$latitude&longitude=$longitude&current=temperature_2m,relative_humidity_2m,wind_speed_10m');
      
      // 2. Fetch AQI (US Index)
      final aqiUri = Uri.parse(
          '$_aqiUrl?latitude=$latitude&longitude=$longitude&current=us_aqi');

      final results = await Future.wait([
        http.get(weatherUri),
        http.get(aqiUri),
      ]);

      final weatherResponse = results[0];
      final aqiResponse = results[1];

      if (weatherResponse.statusCode != 200 || aqiResponse.statusCode != 200) {
        throw Exception('Failed to load weather/AQI data');
      }

      final weatherData = json.decode(weatherResponse.body);
      final aqiData = json.decode(aqiResponse.body);

      final current = weatherData['current'];
      final currentAqi = aqiData['current'];

      return WeatherData(
        temperature: (current['temperature_2m'] as num).toDouble(),
        humidity: (current['relative_humidity_2m'] as num).toDouble(),
        windSpeed: (current['wind_speed_10m'] as num).toDouble(),
        aqi: (currentAqi['us_aqi'] as num).toInt(),
      );

    } catch (e) {
      throw Exception('Error fetching weather data: $e');
    }
  }

  // Deprecated: Use getWeather instead
  Future<double> getTemperature(double latitude, double longitude) async {
    final data = await getWeather(latitude, longitude);
    return data.temperature;
  }
}
