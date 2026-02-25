// lib/screens/monitor/monitor_repository.dart
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'monitor_model.dart';

class MonitorRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ── OpenWeatherMap key (same as weather_repository) ──────────────────────
  static const String _owmKey = '26533d562a121ad3b28f6176a371175d';

  // ─────────────────────────────────────────────────────────────────────────
  // SENSOR STATIONS — from Firestore (real-time stream)
  // In production: your Cloud Function writes station data here periodically
  // from the JPS (Jabatan Pengairan dan Saliran) API or sensor hardware
  // ─────────────────────────────────────────────────────────────────────────
  Stream<List<SensorStation>> watchStations() {
    return _firestore
        .collection('sensor_stations')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => SensorStation.fromFirestore(
                d.data() as Map<String, dynamic>, d.id))
            .toList());
  }

  /// Returns fallback mock stations when Firestore is empty (dev only)
  List<SensorStation> get mockStations => [
        SensorStation(
          id: 'KL-01',
          name: 'Station KL-01',
          river: 'Sungai Klang',
          location: const LatLng(3.1390, 101.6869),
          waterLevel: 2.1,
          warningLevel: 3.0,
          dangerLevel: 4.5,
          flowRate: 38.0,
          rainfall: 12.0,
          lastUpdated: DateTime.now().subtract(const Duration(minutes: 2)),
          isOnline: true,
        ),
        SensorStation(
          id: 'KL-02',
          name: 'Station KL-02',
          river: 'Sungai Gombak',
          location: const LatLng(3.1560, 101.7030),
          waterLevel: 2.8,
          warningLevel: 3.0,
          dangerLevel: 4.5,
          flowRate: 45.0,
          rainfall: 18.0,
          lastUpdated: DateTime.now().subtract(const Duration(minutes: 1)),
          isOnline: true,
        ),
        SensorStation(
          id: 'KL-03',
          name: 'Station KL-03',
          river: 'Sungai Batu',
          location: const LatLng(3.1980, 101.6820),
          waterLevel: 3.4,
          warningLevel: 3.0,
          dangerLevel: 4.5,
          flowRate: 62.0,
          rainfall: 28.0,
          lastUpdated: DateTime.now().subtract(const Duration(minutes: 3)),
          isOnline: true,
        ),
        SensorStation(
          id: 'SL-01',
          name: 'Station SL-01',
          river: 'Sungai Kelang Lama',
          location: const LatLng(3.1100, 101.6750),
          waterLevel: 4.6,
          warningLevel: 3.0,
          dangerLevel: 4.5,
          flowRate: 89.0,
          rainfall: 45.0,
          lastUpdated: DateTime.now().subtract(const Duration(minutes: 5)),
          isOnline: true,
        ),
      ];

  // ─────────────────────────────────────────────────────────────────────────
  // FLOOD ZONES — from Firestore
  // ─────────────────────────────────────────────────────────────────────────
  Stream<List<FloodZone>> watchFloodZones() {
    return _firestore
        .collection('flood_zones')
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final data = d.data() as Map<String, dynamic>;
              final pts = (data['points'] as List? ?? [])
                  .map((p) => LatLng(
                      (p['lat'] as num).toDouble(),
                      (p['lng'] as num).toDouble()))
                  .toList();
              return FloodZone(
                id: d.id,
                name: data['name'] ?? '',
                points: pts,
                risk: FloodRisk.values.firstWhere(
                  (r) => r.name == data['risk'],
                  orElse: () => FloodRisk.low,
                ),
                description: data['description'],
              );
            }).toList());
  }

  /// Mock flood zones for development
  List<FloodZone> get mockFloodZones => [
        FloodZone(
          id: 'z1',
          name: 'Chow Kit Zone',
          points: [
            const LatLng(3.165, 101.694),
            const LatLng(3.160, 101.702),
            const LatLng(3.155, 101.700),
            const LatLng(3.158, 101.692),
          ],
          risk: FloodRisk.critical,
          description: 'Severe flooding — avoid area',
        ),
        FloodZone(
          id: 'z2',
          name: 'Ampang Zone',
          points: [
            const LatLng(3.148, 101.748),
            const LatLng(3.140, 101.758),
            const LatLng(3.135, 101.752),
            const LatLng(3.142, 101.742),
          ],
          risk: FloodRisk.high,
          description: 'High risk — prepare to evacuate',
        ),
        FloodZone(
          id: 'z3',
          name: 'Kepong Zone',
          points: [
            const LatLng(3.208, 101.636),
            const LatLng(3.200, 101.648),
            const LatLng(3.195, 101.642),
            const LatLng(3.200, 101.630),
          ],
          risk: FloodRisk.moderate,
          description: 'Moderate risk — stay alert',
        ),
      ];

  // ─────────────────────────────────────────────────────────────────────────
  // ROAD CLOSURES — real-time stream + submit new report
  // ─────────────────────────────────────────────────────────────────────────
  Stream<List<RoadClosure>> watchRoadClosures() {
    return _firestore
        .collection('road_closures')
        .orderBy('reportedAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => RoadClosure.fromFirestore(
                d.data() as Map<String, dynamic>, d.id))
            .toList());
  }

  Future<void> reportRoadClosure({
    required LatLng location,
    required String description,
    required String reportedBy,
  }) async {
    final closure = RoadClosure(
      id: '',
      location: location,
      reportedBy: reportedBy,
      description: description,
      reportedAt: DateTime.now(),
      confirmedCount: 0,
      isVerified: false,
    );

    await _firestore
        .collection('road_closures')
        .add(closure.toFirestore());
  }

  Future<void> confirmRoadClosure(String closureId) async {
    await _firestore
        .collection('road_closures')
        .doc(closureId)
        .update({'confirmedCount': FieldValue.increment(1)});
  }

  // ─────────────────────────────────────────────────────────────────────────
  // WATER LEVEL HISTORY — from OpenWeatherMap hourly data
  // Returns last 24 data points
  // ─────────────────────────────────────────────────────────────────────────
  Future<List<WaterLevelPoint>> fetchWaterLevelHistory({
    required double lat,
    required double lon,
    String stationId = 'KL-01',
  }) async {
    // Try Firestore history first
    try {
      final snap = await _firestore
          .collection('sensor_stations')
          .doc(stationId)
          .collection('history')
          .orderBy('time', descending: true)
          .limit(24)
          .get();

      if (snap.docs.isNotEmpty) {
        return snap.docs.reversed.map((d) {
          final data = d.data() as Map<String, dynamic>;
          return WaterLevelPoint(
            time: DateTime.tryParse(data['time'] ?? '') ?? DateTime.now(),
            level: (data['level'] as num?)?.toDouble() ?? 0,
          );
        }).toList();
      }
    } catch (_) {}

    // Fallback: derive approximate history from rainfall forecast
    try {
      final resp = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast'
        '?lat=$lat&lon=$lon&units=metric&cnt=8&appid=$_owmKey',
      ));

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final list = data['list'] as List;
        return list.asMap().entries.map((e) {
          final rain = (e.value['rain']?['3h'] ?? 0.0).toDouble();
          // Approx: every 5mm rain = +0.1m water level rise
          final level = 1.5 + (rain * 0.02) + (e.key * 0.05);
          return WaterLevelPoint(
            time: DateTime.now()
                .subtract(Duration(hours: (7 - e.key) * 3)),
            level: level.clamp(0.5, 5.0),
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('fetchWaterLevelHistory error: $e');
    }

    // Static fallback
    return _mockHistory();
  }

  List<WaterLevelPoint> _mockHistory() {
    final now = DateTime.now();
    final levels = [1.8, 1.9, 2.1, 2.3, 2.5, 2.4, 2.6, 2.8,
                    3.0, 3.2, 3.1, 2.9, 2.7, 2.8, 3.0, 3.2,
                    3.4, 3.3, 3.1, 3.0, 2.9, 3.1, 3.3, 3.5];
    return levels.asMap().entries.map((e) => WaterLevelPoint(
          time: now.subtract(Duration(hours: 23 - e.key)),
          level: e.value,
        )).toList();
  }
}

// ignore: avoid_print
void debugPrint(String msg) => print(msg);