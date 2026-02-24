// lib/screens/home/weather_viewmodel.dart
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'weather_model.dart';
import 'weather_repository.dart';

class WeatherViewModel extends ChangeNotifier {
  final WeatherRepository _repository = WeatherRepository();

  WeatherModel? _weather;
  bool _isLoading = false;
  String? _error;

  WeatherModel? get weather => _weather;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadWeather(String city) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _weather = await _repository.getWeatherByCity(city);
    _error = _weather == null ? 'Could not load weather for $city' : null;

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadWeatherByLocation() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Check location services
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('⚠️ Location services disabled, falling back to KL');
        await _fallbackToKL();
        return;
      }

      // Check/request permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        print('⚠️ Location permission denied, falling back to KL');
        await _fallbackToKL();
        return;
      }

      // Get GPS position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );
      print('📍 Got position: ${position.latitude}, ${position.longitude}');

      _weather = await _repository.getWeatherByCoords(
        position.latitude,
        position.longitude,
      );

      // Fall back to KL if coords call failed
      if (_weather == null) {
        print('⚠️ Coords lookup failed, falling back to KL');
        await _fallbackToKL();
        return;
      }
    } catch (e) {
      print('💥 loadWeatherByLocation error: $e');
      await _fallbackToKL();
      return;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _fallbackToKL() async {
    _weather = await _repository.getWeatherByCity('Kuala Lumpur');
    _error = _weather == null ? 'Could not load weather data' : null;
    _isLoading = false;
    notifyListeners();
  }
}