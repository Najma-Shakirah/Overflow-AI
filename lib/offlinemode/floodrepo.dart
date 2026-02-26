import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class FloodLocation {
  final String id;
  final double lat;
  final double lng;
  final String severity; // 'low', 'medium', 'high'
  final DateTime updatedAt;

  FloodLocation({
    required this.id,
    required this.lat,
    required this.lng,
    required this.severity,
    required this.updatedAt,
  });

  factory FloodLocation.fromFirestore(Map<String, dynamic> data, String id) {
    return FloodLocation(
      id: id,
      lat: (data['lat'] as num).toDouble(),
      lng: (data['lng'] as num).toDouble(),
      severity: data['severity'] ?? 'low',
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'lat': lat,
      'lng': lng,
      'severity': severity,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

class FloodRepository {
  final _firestore = FirebaseFirestore.instance;
  final _connectivity = Connectivity();

  bool _isOnline = true;
  bool get isOnline => _isOnline;

  FloodRepository() {
    // Track connectivity so the UI can show the offline banner
    _connectivity.onConnectivityChanged.listen((result) {
      _isOnline = result != ConnectivityResult.none;
    });

    _connectivity.checkConnectivity().then((result) {
      _isOnline = result != ConnectivityResult.none;
    });
  }

  /// Stream of flood locations.
  /// Firestore automatically serves from cache when offline —
  /// no extra code needed on your part.
  Stream<List<FloodLocation>> watchFloodLocations() {
    return _firestore
        .collection('flood_locations')
        .snapshots(
          // includeMetadataChanges: true lets you know if data
          // came from cache vs server (optional, used for the banner)
          includeMetadataChanges: true,
        )
        .map((snapshot) => snapshot.docs
            .map((doc) => FloodLocation.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  /// Add or update a flood marker.
  /// Works offline — Firestore queues the write and sends it
  /// automatically when the device reconnects.
  Future<void> saveFloodLocation(FloodLocation location) async {
    await _firestore
        .collection('flood_locations')
        .doc(location.id)
        .set(location.toFirestore());
    // No extra offline handling needed — Firestore does it automatically!
  }

  /// Delete a flood marker.
  /// Also works offline — queued and synced automatically.
  Future<void> deleteFloodLocation(String id) async {
    await _firestore.collection('flood_locations').doc(id).delete();
  }
}