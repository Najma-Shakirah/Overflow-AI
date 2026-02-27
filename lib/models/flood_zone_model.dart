class FloodZone {
  final String zoneId;
  final String name;
  final String state;
  final String severity;
  final double lat;
  final double lng;
  final double radiusMeters;
  final bool isActive;
  final DateTime lastUpdated;
  final String? description;

  const FloodZone({
    required this.zoneId,
    required this.name,
    required this.state,
    required this.severity,
    required this.lat,
    required this.lng,
    required this.radiusMeters,
    required this.isActive,
    required this.lastUpdated,
    this.description,
  });

  factory FloodZone.fromMap(String key, Map<dynamic, dynamic> data) {
    return FloodZone(
      zoneId: key,
      name: data['name'] as String,
      state: data['state'] as String,
      severity: data['severity'] as String,
      lat: (data['lat'] as num).toDouble(),
      lng: (data['lng'] as num).toDouble(),
      radiusMeters: (data['radius_meters'] as num).toDouble(),
      isActive: data['is_active'] as bool,
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(
          data['last_updated'] as int),
      description: data['description'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'zoneId': zoneId,
    'name': name,
    'state': state,
    'severity': severity,
    'lat': lat,
    'lng': lng,
    'radiusMeters': radiusMeters,
    'isActive': isActive,
    'lastUpdated': lastUpdated.millisecondsSinceEpoch,
    'description': description,
  };

  factory FloodZone.fromStoredMap(Map<dynamic, dynamic> data) {
    return FloodZone(
      zoneId: data['zoneId'] as String,
      name: data['name'] as String,
      state: data['state'] as String,
      severity: data['severity'] as String,
      lat: (data['lat'] as num).toDouble(),
      lng: (data['lng'] as num).toDouble(),
      radiusMeters: (data['radiusMeters'] as num).toDouble(),
      isActive: data['isActive'] as bool,
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(
          data['lastUpdated'] as int),
      description: data['description'] as String?,
    );
  }
}