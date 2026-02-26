// lib/screens/monitor/monitor_viewmodel.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'monitor_model.dart';
import 'monitor_repository.dart';

class MonitorViewModel extends ChangeNotifier {
  final MonitorRepository _repo;

  MonitorViewModel({MonitorRepository? repository})
      : _repo = repository ?? MonitorRepository() {
    _init();
  }

  // ── State ─────────────────────────────────────────────────────────────────
  List<SensorStation> _stations = [];
  List<FloodZone> _floodZones = [];
  List<RoadClosure> _roadClosures = [];
  List<WaterLevelPoint> _waterHistory = [];
  SensorStation? _selectedStation;
  MapLayerState _layers = const MapLayerState();
  bool _isLoading = true;
  bool _isOffline = false;          // ← NEW
  bool _isSubmittingClosure = false;
  String? _error;
  LatLng _mapCenter = const LatLng(3.1390, 101.6869);

  // ── Getters ───────────────────────────────────────────────────────────────
  List<SensorStation> get stations => _stations;
  List<FloodZone> get floodZones => _floodZones;
  List<RoadClosure> get roadClosures => _roadClosures;
  List<WaterLevelPoint> get waterHistory => _waterHistory;
  SensorStation? get selectedStation => _selectedStation;
  MapLayerState get layers => _layers;
  bool get isLoading => _isLoading;
  bool get isOffline => _isOffline;  // ← NEW
  bool get isSubmittingClosure => _isSubmittingClosure;
  String? get error => _error;
  LatLng get mapCenter => _mapCenter;

  int get dangerStationCount =>
      _stations.where((s) => s.status == StationStatus.danger).length;
  int get warningStationCount =>
      _stations.where((s) => s.status == StationStatus.warning).length;
  int get activeRoadClosures => _roadClosures.length;

  SensorStation? get mostCriticalStation {
    if (_stations.isEmpty) return null;
    return _stations
        .reduce((a, b) => a.waterLevel > b.waterLevel ? a : b);
  }

  FloodSituation get overallSituation {
    if (dangerStationCount > 0) return FloodSituation.danger;
    if (warningStationCount > 0) return FloodSituation.warning;
    return FloodSituation.normal;
  }

  // ── Subscriptions ─────────────────────────────────────────────────────────
  StreamSubscription<List<SensorStation>>? _stationSub;
  StreamSubscription<List<FloodZone>>? _zoneSub;
  StreamSubscription<List<RoadClosure>>? _closureSub;

  Future<void> _init() async {
    _isLoading = true;
    _isOffline = await _repo.isOffline;   // ← check connectivity once
    notifyListeners();

    // Stations — Firestore online, Hive cache offline
    _stationSub = _repo.watchStations().listen(
      (stations) {
        _stations = stations;
        _isLoading = false;
        _error = null;
        notifyListeners();
        _loadHistory();
      },
      onError: (_) {
        _stations = _repo.mockStations;
        _isLoading = false;
        notifyListeners();
        _loadHistory();
      },
    );

    // Flood zones — Firestore online, Hive cache offline
    _zoneSub = _repo.watchFloodZones().listen(
      (zones) {
        _floodZones = zones;
        notifyListeners();
      },
      onError: (_) {
        _floodZones = _repo.mockFloodZones;
        notifyListeners();
      },
    );

    // Road closures — online only, skip entirely when offline
    if (!_isOffline) {
      _closureSub = _repo.watchRoadClosures().listen(
        (closures) {
          _roadClosures = closures;
          notifyListeners();
        },
        onError: (_) {},
      );
    }
  }

  Future<void> _loadHistory() async {
    final station = _selectedStation ?? mostCriticalStation;
    if (station == null) return;
    _waterHistory = await _repo.fetchWaterLevelHistory(
      lat: station.location.latitude,
      lon: station.location.longitude,
      stationId: station.id,
    );
    notifyListeners();
  }

  // ── Actions ───────────────────────────────────────────────────────────────
  void selectStation(SensorStation station) {
    _selectedStation = station;
    _mapCenter = station.location;
    notifyListeners();
    _loadHistory();
  }

  void clearSelectedStation() {
    _selectedStation = null;
    notifyListeners();
  }

  void toggleLayer(String layer) {
    switch (layer) {
      case 'floodZones':
        _layers =
            _layers.copyWith(showFloodZones: !_layers.showFloodZones);
        break;
      case 'stations':
        _layers =
            _layers.copyWith(showStations: !_layers.showStations);
        break;
      case 'roadClosures':
        _layers = _layers.copyWith(
            showRoadClosures: !_layers.showRoadClosures);
        break;
      case 'heatmap':
        _layers =
            _layers.copyWith(showHeatmap: !_layers.showHeatmap);
        break;
    }
    notifyListeners();
  }

  Future<void> reportRoadClosure({
    required LatLng location,
    required String description,
    required String reportedBy,
  }) async {
    if (_isOffline) return;  // guard — button is hidden in UI but guard here too
    _isSubmittingClosure = true;
    notifyListeners();
    try {
      await _repo.reportRoadClosure(
        location: location,
        description: description,
        reportedBy: reportedBy,
      );
    } catch (e) {
      _error = 'Failed to submit road closure report.';
    }
    _isSubmittingClosure = false;
    notifyListeners();
  }

  Future<void> confirmRoadClosure(String closureId) async {
    if (_isOffline) return;
    try {
      await _repo.confirmRoadClosure(closureId);
    } catch (e) {
      debugPrint('confirmRoadClosure error: $e');
    }
  }

  Future<void> refresh() async {
    // Cancel existing subscriptions and re-init with fresh connectivity check
    await _stationSub?.cancel();
    await _zoneSub?.cancel();
    await _closureSub?.cancel();
    _stations = [];
    _floodZones = [];
    _roadClosures = [];
    await _init();
  }

  @override
  void dispose() {
    _stationSub?.cancel();
    _zoneSub?.cancel();
    _closureSub?.cancel();
    super.dispose();
  }
}

enum FloodSituation { normal, warning, danger }