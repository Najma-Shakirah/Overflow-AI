// lib/screens/home/weather_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'weather_model.dart';

class WeatherRepository {
  static const String _apiKey = '26533d562a121ad3b28f6176a371175d';

  // Free tier endpoints — no subscription required
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  /// Get current weather by GPS coordinates (free)
  Future<WeatherModel?> getWeatherByCoords(double lat, double lon) async {
    try {
      final url = '$_baseUrl/weather'
          '?lat=$lat&lon=$lon'
          '&units=metric'   // Celsius
          '&appid=$_apiKey';

      print('🌐 Fetching weather by coords: $lat, $lon');
      final response = await http.get(Uri.parse(url));
      print('📡 Status: ${response.statusCode}');
      print('📦 Body: ${response.body}');

      if (response.statusCode == 200) {
        final model = WeatherModel.fromJson(jsonDecode(response.body));
        print('✅ Loaded: ${model.temperature}°C at ${model.location}');
        return model;
      }

      print('❌ Error ${response.statusCode}: ${response.body}');
      return null;
    } catch (e) {
      print('💥 getWeatherByCoords error: $e');
      return null;
    }
  }

  /// Get current weather by city name (free)
  Future<WeatherModel?> getWeatherByCity(String city) async {
    try {
      final url = '$_baseUrl/weather'
          '?q=$city,MY'
          '&units=metric'
          '&appid=$_apiKey';

      print('🏙️ Fetching weather for city: $city');
      final response = await http.get(Uri.parse(url));
      print('📡 Status: ${response.statusCode}');
      print('📦 Body: ${response.body}');

      if (response.statusCode == 200) {
        final model = WeatherModel.fromJson(jsonDecode(response.body));
        print('✅ Loaded: ${model.temperature}°C at ${model.location}');
        return model;
      }

      print('❌ Error ${response.statusCode}: ${response.body}');
      return null;
    } catch (e) {
      print('💥 getWeatherByCity error: $e');
      return null;
    }
  }

  /// Get 5-day forecast in 3-hour steps (free, max 40 entries)
  Future<List<Map<String, dynamic>>> getForecast(String city) async {
    try {
      final url = '$_baseUrl/forecast'
          '?q=$city,MY'
          '&units=metric'
          '&cnt=8'   // next 24hrs (8 x 3hr = 24hr)
          '&appid=$_apiKey';

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['list']);
      }
      return [];
    } catch (e) {
      print('💥 getForecast error: $e');
      return [];
    }
  }
}