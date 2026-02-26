// lib/screens/monitor/monitor_repository.dart
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'monitor_model.dart';

class MonitorRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _owmKey = 'YOUR_OPENWEATHERMAP_API_KEY';

  // Hive box names — opened once in main() via openBoxes()
  static const String _stationsBox = 'monitor_stations';
  static const String _zonesBox = 'monitor_zones';

  /// Call this once from main() alongside HiveService.init()
  static Future<void> openBoxes() async {
    await Hive.openBox<String>(_stationsBox);
    await Hive.openBox<String>(_zonesBox);
  }

  // ── Connectivity ──────────────────────────────────────────────────────────
  Future<bool> get isOffline async {
    final result = await Connectivity().checkConnectivity();
    return result == ConnectivityResult.none;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SENSOR STATIONS
  // Online  → stream Firestore, auto-save each update to Hive
  // Offline → read from Hive cache (or mock if cache empty)
  // ─────────────────────────────────────────────────────────────────────────
  Stream<List<SensorStation>> watchStations() async* {
    if (await isOffline) {
      yield _loadCachedStations();
      return;
    }

    yield* _firestore.collection('sensor_stations').snapshots().map((snap) {
      final stations = snap.docs
          .map((d) => SensorStation.fromFirestore(
              d.data() as Map<String, dynamic>, d.id))
          .toList();

      final result = stations.isEmpty ? mockStations : stations;
      if (stations.isNotEmpty) _cacheStations(stations);
      return result;
    });
  }

  List<SensorStation> _loadCachedStations() {
    final box = Hive.box<String>(_stationsBox);
    if (box.isEmpty) return mockStations;
    try {
      return box.values.map((json) {
        final d = jsonDecode(json) as Map<String, dynamic>;
        return SensorStation(
          id: d['id'] as String,
          name: d['name'] as String,
          river: d['river'] as String,
          location: LatLng(
            (d['lat'] as num).toDouble(),
            (d['lng'] as num).toDouble(),
          ),
          waterLevel: (d['waterLevel'] as num).toDouble(),
          warningLevel: (d['warningLevel'] as num).toDouble(),
          dangerLevel: (d['dangerLevel'] as num).toDouble(),
          flowRate: (d['flowRate'] as num).toDouble(),
          rainfall: (d['rainfall'] as num).toDouble(),
          lastUpdated: DateTime.parse(d['lastUpdated'] as String),
          isOnline: d['isOnline'] as bool,
        );
      }).toList();
    } catch (_) {
      return mockStations;
    }
  }

  Future<void> _cacheStations(List<SensorStation> stations) async {
    final box = Hive.box<String>(_stationsBox);
    await box.clear();
    for (final s in stations) {
      await box.put(
        s.id,
        jsonEncode({
          'id': s.id,
          'name': s.name,
          'river': s.river,
          'lat': s.location.latitude,
          'lng': s.location.longitude,
          'waterLevel': s.waterLevel,
          'warningLevel': s.warningLevel,
          'dangerLevel': s.dangerLevel,
          'flowRate': s.flowRate,
          'rainfall': s.rainfall,
          'lastUpdated': s.lastUpdated.toIso8601String(),
          'isOnline': s.isOnline,
        }),
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // FLOOD ZONES
  // Online  → stream Firestore, auto-save each update to Hive
  // Offline → read from Hive cache (or mock if cache empty)
  // ─────────────────────────────────────────────────────────────────────────
  Stream<List<FloodZone>> watchFloodZones() async* {
    if (await isOffline) {
      yield _loadCachedZones();
      return;
    }

    yield* _firestore.collection('flood_zones').snapshots().map((snap) {
      final zones = snap.docs.map((d) {
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
      }).toList();

      final result = zones.isEmpty ? mockFloodZones : zones;
      if (zones.isNotEmpty) _cacheZones(zones);
      return result;
    });
  }

  List<FloodZone> _loadCachedZones() {
    final box = Hive.box<String>(_zonesBox);
    if (box.isEmpty) return mockFloodZones;
    try {
      return box.values.map((json) {
        final d = jsonDecode(json) as Map<String, dynamic>;
        final pts = (d['points'] as List)
            .map((p) => LatLng(
                (p['lat'] as num).toDouble(),
                (p['lng'] as num).toDouble()))
            .toList();
        return FloodZone(
          id: d['id'] as String,
          name: d['name'] as String,
          points: pts,
          risk: FloodRisk.values.firstWhere(
            (r) => r.name == d['risk'],
            orElse: () => FloodRisk.low,
          ),
          description: d['description'] as String?,
        );
      }).toList();
    } catch (_) {
      return mockFloodZones;
    }
  }

  Future<void> _cacheZones(List<FloodZone> zones) async {
    final box = Hive.box<String>(_zonesBox);
    await box.clear();
    for (final z in zones) {
      await box.put(
        z.id,
        jsonEncode({
          'id': z.id,
          'name': z.name,
          'points': z.points
              .map((p) => {'lat': p.latitude, 'lng': p.longitude})
              .toList(),
          'risk': z.risk.name,
          'description': z.description,
        }),
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ROAD CLOSURES — online only (crowdsourced data goes stale fast)
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
  // WATER LEVEL HISTORY
  // ─────────────────────────────────────────────────────────────────────────
  Future<List<WaterLevelPoint>> fetchWaterLevelHistory({
    required double lat,
    required double lon,
    String stationId = 'KL-01',
  }) async {
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

    return _mockHistory();
  }

  List<WaterLevelPoint> _mockHistory() {
    final now = DateTime.now();
    final levels = [
      1.8, 1.9, 2.1, 2.3, 2.5, 2.4, 2.6, 2.8,
      3.0, 3.2, 3.1, 2.9, 2.7, 2.8, 3.0, 3.2,
      3.4, 3.3, 3.1, 3.0, 2.9, 3.1, 3.3, 3.5,
    ];
    return levels.asMap().entries.map((e) => WaterLevelPoint(
          time: now.subtract(Duration(hours: 23 - e.key)),
          level: e.value,
        )).toList();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // MOCK DATA
  // ─────────────────────────────────────────────────────────────────────────
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
          lastUpdated:
              DateTime.now().subtract(const Duration(minutes: 2)),
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
          lastUpdated:
              DateTime.now().subtract(const Duration(minutes: 1)),
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
          lastUpdated:
              DateTime.now().subtract(const Duration(minutes: 3)),
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
          lastUpdated:
              DateTime.now().subtract(const Duration(minutes: 5)),
          isOnline: true,
        ),
      ];

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
}