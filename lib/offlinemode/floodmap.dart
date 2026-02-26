/*import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'flood_repository.dart';

class FloodMapViewModel extends ChangeNotifier {
  final FloodRepository _repo;

  FloodMapViewModel(this._repo) {
    _init();
  }

  List<FloodLocation> _locations = [];
  bool _isFromCache = false;
  bool _isLoading = true;
  String? _error;

  StreamSubscription? _locationSub;
  StreamSubscription? _metaSub;

  List<FloodLocation> get locations => _locations;
  bool get isOnline => _repo.isOnline;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Show banner when offline OR when Firestore is still loading from server
  bool get showOfflineBanner => !_repo.isOnline || _isFromCache;

  String get offlineBannerMessage {
    if (!_repo.isOnline) return 'You\'re offline — showing cached flood data';
    if (_isFromCache) return 'Syncing latest data…';
    return '';
  }

  Set<Marker> get markers => _locations
      .map((l) => Marker(
            markerId: MarkerId(l.id),
            position: LatLng(l.lat, l.lng),
            icon: _iconForSeverity(l.severity),
            infoWindow: InfoWindow(
              title: 'Flood Alert',
              snippet: 'Severity: ${l.severity.toUpperCase()}',
            ),
          ))
      .toSet();

  void _init() {
    // Stream of flood locations (auto-serves from cache when offline)
    _locationSub = _repo.watchFloodLocations().listen(
      (locations) {
        _locations = locations;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );

    // Detect whether data is coming from cache or live server
    _metaSub = FirebaseFirestore.instance
        .collection('flood_locations')
        .snapshots(includeMetadataChanges: true)
        .listen((snapshot) {
      final wasFromCache = _isFromCache;
      _isFromCache = snapshot.metadata.isFromCache;
      if (wasFromCache != _isFromCache) notifyListeners();
    });
  }

  Future<void> addFloodMarker({
    required double lat,
    required double lng,
    required String severity,
  }) async {
    final location = FloodLocation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      lat: lat,
      lng: lng,
      severity: severity,
      updatedAt: DateTime.now(),
    );
    // Works offline automatically — Firestore queues and syncs on reconnect
    await _repo.saveFloodLocation(location);
  }

  Future<void> deleteFloodMarker(String id) async {
    await _repo.deleteFloodLocation(id);
  }

  BitmapDescriptor _iconForSeverity(String severity) {
    switch (severity) {
      case 'high':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      case 'medium':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
      default:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
    }
  }

  @override
  void dispose() {
    _locationSub?.cancel();
    _metaSub?.cancel();
    super.dispose();
  }
}
*/