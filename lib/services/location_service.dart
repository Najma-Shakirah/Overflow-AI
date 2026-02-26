// lib/services/location_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class LocationResult {
  final double lat;
  final double lng;
  final String district; // e.g. "Shah Alam"
  final String state;    // e.g. "Selangor"
  final String display;  // e.g. "Shah Alam, Selangor"

  const LocationResult({
    required this.lat,
    required this.lng,
    required this.district,
    required this.state,
    required this.display,
  });
}

class LocationService {
  // Uses OpenStreetMap Nominatim — completely free, no API key needed
  static const String _nominatimBase =
      'https://nominatim.openstreetmap.org/reverse';

  // ── MAIN ENTRY POINT ───────────────────────────────────
  // Returns the user's current location as a Malaysian district/state.
  // Falls back to Kuala Lumpur if anything fails.
  static Future<LocationResult> getCurrentLocation() async {
    try {
      final position = await _getPosition();
      final result = await _reverseGeocode(position.latitude, position.longitude);
      return result;
    } catch (e) {
      debugPrint('LocationService error: $e');
      return _fallback();
    }
  }

  // ── GPS ────────────────────────────────────────────────
  static Future<Position> _getPosition() async {
    // Check if location services are enabled
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    // Check/request permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied');
    }

    // Get position — use low accuracy for speed, we only need city-level
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low,
        timeLimit: Duration(seconds: 10),
      ),
    );
  }

  // ── REVERSE GEOCODE via OpenStreetMap Nominatim ────────
  // Free, no API key, covers Malaysia well.
  // Returns district + state from GPS coordinates.
  static Future<LocationResult> _reverseGeocode(
    double lat,
    double lng,
  ) async {
    final uri = Uri.parse(
      '$_nominatimBase?lat=$lat&lon=$lng&format=json&addressdetails=1',
    );

    final resp = await http.get(
      uri,
      headers: {
        // Nominatim requires a User-Agent header
        'User-Agent': 'OverflowAI-FloodApp/1.0',
      },
    ).timeout(const Duration(seconds: 8));

    if (resp.statusCode != 200) {
      debugPrint('Nominatim error: ${resp.statusCode}');
      return _fallback(lat: lat, lng: lng);
    }

    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final address = data['address'] as Map<String, dynamic>? ?? {};

    debugPrint('Nominatim raw address: $address');

    // Extract district — Nominatim uses different keys for Malaysia
    // Try in order of specificity
    final district = _extractDistrict(address);
    final state = _extractState(address);

    debugPrint('Resolved: $district, $state');

    return LocationResult(
      lat: lat,
      lng: lng,
      district: district,
      state: state,
      display: '$district, $state',
    );
  }

  // ── FIELD EXTRACTORS ───────────────────────────────────
  // Nominatim returns Malaysian addresses with varying field names.
  // This handles all the common cases.
  static String _extractDistrict(Map<String, dynamic> address) {
    // Try these fields in order — most specific first
    for (final key in [
      'suburb',        // e.g. "Seksyen 14"
      'quarter',
      'neighbourhood',
      'city_district',
      'district',      // e.g. "Petaling"
      'town',          // e.g. "Shah Alam"
      'city',          // e.g. "Kuala Lumpur"
      'municipality',
      'county',
    ]) {
      final val = address[key] as String?;
      if (val != null && val.isNotEmpty) return _cleanName(val);
    }
    return 'Kuala Lumpur';
  }

  static String _extractState(Map<String, dynamic> address) {
    final state = address['state'] as String? ?? '';
    if (state.isNotEmpty) return _cleanName(state);

    // Some entries use 'region'
    final region = address['region'] as String? ?? '';
    if (region.isNotEmpty) return _cleanName(region);

    return 'Kuala Lumpur';
  }

  // Clean up common Nominatim quirks for Malaysian addresses
  static String _cleanName(String name) {
    return name
        .replaceAll('Federal Territory of ', '')
        .replaceAll('Wilayah Persekutuan ', '')
        .trim();
  }

  // ── FALLBACK ───────────────────────────────────────────
  static LocationResult _fallback({double? lat, double? lng}) {
    return LocationResult(
      lat: lat ?? 3.1390,
      lng: lng ?? 101.6869,
      district: 'Kuala Lumpur',
      state: 'Kuala Lumpur',
      display: 'Kuala Lumpur',
    );
  }
}