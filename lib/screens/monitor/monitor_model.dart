// lib/screens/monitor/monitor_model.dart
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

// ─── Sensor Station ──────────────────────────────────────────────────────────
class SensorStation {
  final String id;
  final String name;
  final String river;
  final LatLng location;
  final double waterLevel;    // metres
  final double warningLevel;  // metres
  final double dangerLevel;   // metres
  final double flowRate;      // m³/s
  final double rainfall;      // mm/hr
  final DateTime lastUpdated;
  final bool isOnline;

  SensorStation({
    required this.id,
    required this.name,
    required this.river,
    required this.location,
    required this.waterLevel,
    required this.warningLevel,
    required this.dangerLevel,
    required this.flowRate,
    required this.rainfall,
    required this.lastUpdated,
    required this.isOnline,
  });

  StationStatus get status {
    if (!isOnline) return StationStatus.offline;
    if (waterLevel >= dangerLevel) return StationStatus.danger;
    if (waterLevel >= warningLevel) return StationStatus.warning;
    return StationStatus.normal;
  }

  Color get statusColor {
    switch (status) {
      case StationStatus.danger: return const Color(0xFFD32F2F);
      case StationStatus.warning: return const Color(0xFFF57C00);
      case StationStatus.offline: return Colors.grey;
      case StationStatus.normal: return const Color(0xFF388E3C);
    }
  }

  String get statusLabel {
    switch (status) {
      case StationStatus.danger: return 'Danger';
      case StationStatus.warning: return 'Warning';
      case StationStatus.offline: return 'Offline';
      case StationStatus.normal: return 'Normal';
    }
  }

  /// How full the river is as 0.0–1.0
  double get levelFraction =>
      (waterLevel / dangerLevel).clamp(0.0, 1.0);

  String get lastUpdatedLabel {
    final diff = DateTime.now().difference(lastUpdated);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }

  factory SensorStation.fromFirestore(Map<String, dynamic> d, String id) {
    return SensorStation(
      id: id,
      name: d['name'] ?? '',
      river: d['river'] ?? '',
      location: LatLng(
        (d['lat'] as num).toDouble(),
        (d['lng'] as num).toDouble(),
      ),
      waterLevel: (d['waterLevel'] as num?)?.toDouble() ?? 0,
      warningLevel: (d['warningLevel'] as num?)?.toDouble() ?? 3.0,
      dangerLevel: (d['dangerLevel'] as num?)?.toDouble() ?? 4.5,
      flowRate: (d['flowRate'] as num?)?.toDouble() ?? 0,
      rainfall: (d['rainfall'] as num?)?.toDouble() ?? 0,
      lastUpdated: d['lastUpdated'] != null
          ? DateTime.tryParse(d['lastUpdated']) ?? DateTime.now()
          : DateTime.now(),
      isOnline: d['isOnline'] ?? true,
    );
  }
}

enum StationStatus { normal, warning, danger, offline }

// ─── Flood Zone (map polygon) ─────────────────────────────────────────────────
class FloodZone {
  final String id;
  final String name;
  final List<LatLng> points;
  final FloodRisk risk;
  final String? description;

  FloodZone({
    required this.id,
    required this.name,
    required this.points,
    required this.risk,
    this.description,
  });

  Color get fillColor {
    switch (risk) {
      case FloodRisk.critical: return const Color(0xFFD32F2F).withOpacity(0.35);
      case FloodRisk.high: return const Color(0xFFF57C00).withOpacity(0.3);
      case FloodRisk.moderate: return const Color(0xFFFBC02D).withOpacity(0.25);
      case FloodRisk.low: return const Color(0xFF388E3C).withOpacity(0.15);
    }
  }

  Color get borderColor {
    switch (risk) {
      case FloodRisk.critical: return const Color(0xFFD32F2F);
      case FloodRisk.high: return const Color(0xFFF57C00);
      case FloodRisk.moderate: return const Color(0xFFFBC02D);
      case FloodRisk.low: return const Color(0xFF388E3C);
    }
  }

  String get riskLabel {
    switch (risk) {
      case FloodRisk.critical: return 'CRITICAL';
      case FloodRisk.high: return 'HIGH';
      case FloodRisk.moderate: return 'MODERATE';
      case FloodRisk.low: return 'LOW';
    }
  }
}

enum FloodRisk { low, moderate, high, critical }

// ─── Road Closure (crowdsourced) ─────────────────────────────────────────────
class RoadClosure {
  final String id;
  final LatLng location;
  final String reportedBy;
  final String description;
  final DateTime reportedAt;
  final int confirmedCount;
  final bool isVerified;

  RoadClosure({
    required this.id,
    required this.location,
    required this.reportedBy,
    required this.description,
    required this.reportedAt,
    required this.confirmedCount,
    required this.isVerified,
  });

  String get timeAgo {
    final diff = DateTime.now().difference(reportedAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }

  factory RoadClosure.fromFirestore(Map<String, dynamic> d, String id) {
    return RoadClosure(
      id: id,
      location: LatLng(
        (d['lat'] as num).toDouble(),
        (d['lng'] as num).toDouble(),
      ),
      reportedBy: d['reportedBy'] ?? 'Anonymous',
      description: d['description'] ?? 'Road impassable',
      reportedAt: d['reportedAt'] != null
          ? DateTime.tryParse(d['reportedAt']) ?? DateTime.now()
          : DateTime.now(),
      confirmedCount: (d['confirmedCount'] as num?)?.toInt() ?? 0,
      isVerified: d['isVerified'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'lat': location.latitude,
    'lng': location.longitude,
    'reportedBy': reportedBy,
    'description': description,
    'reportedAt': reportedAt.toIso8601String(),
    'confirmedCount': confirmedCount,
    'isVerified': isVerified,
  };
}

// ─── Water level history point ────────────────────────────────────────────────
class WaterLevelPoint {
  final DateTime time;
  final double level;

  WaterLevelPoint({required this.time, required this.level});
}

// ─── Map layer toggle state ───────────────────────────────────────────────────
class MapLayerState {
  final bool showFloodZones;
  final bool showStations;
  final bool showRoadClosures;
  final bool showHeatmap;

  const MapLayerState({
    this.showFloodZones = true,
    this.showStations = true,
    this.showRoadClosures = true,
    this.showHeatmap = false,
  });

  MapLayerState copyWith({
    bool? showFloodZones,
    bool? showStations,
    bool? showRoadClosures,
    bool? showHeatmap,
  }) =>
      MapLayerState(
        showFloodZones: showFloodZones ?? this.showFloodZones,
        showStations: showStations ?? this.showStations,
        showRoadClosures: showRoadClosures ?? this.showRoadClosures,
        showHeatmap: showHeatmap ?? this.showHeatmap,
      );
}