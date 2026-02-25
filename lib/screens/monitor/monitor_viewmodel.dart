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
  bool _isSubmittingClosure = false;
  String? _error;

  // Map center — defaults to KL
  LatLng _mapCenter = const LatLng(3.1390, 101.6869);

  // ── Getters ───────────────────────────────────────────────────────────────
  List<SensorStation> get stations => _stations;
  List<FloodZone> get floodZones => _floodZones;
  List<RoadClosure> get roadClosures => _roadClosures;
  List<WaterLevelPoint> get waterHistory => _waterHistory;
  SensorStation? get selectedStation => _selectedStation;
  MapLayerState get layers => _layers;
  bool get isLoading => _isLoading;
  bool get isSubmittingClosure => _isSubmittingClosure;
  String? get error => _error;
  LatLng get mapCenter => _mapCenter;

  // ── Derived stats ─────────────────────────────────────────────────────────
  int get dangerStationCount =>
      _stations.where((s) => s.status == StationStatus.danger).length;
  int get warningStationCount =>
      _stations.where((s) => s.status == StationStatus.warning).length;
  int get activeRoadClosures => _roadClosures.length;

  SensorStation? get mostCriticalStation {
    if (_stations.isEmpty) return null;
    return _stations.reduce((a, b) => a.waterLevel > b.waterLevel ? a : b);
  }

  // Overall flood situation
  FloodSituation get overallSituation {
    if (dangerStationCount > 0) return FloodSituation.danger;
    if (warningStationCount > 0) return FloodSituation.warning;
    return FloodSituation.normal;
  }

  // ── Stream subscriptions ──────────────────────────────────────────────────
  StreamSubscription<List<SensorStation>>? _stationSub;
  StreamSubscription<List<FloodZone>>? _zoneSub;
  StreamSubscription<List<RoadClosure>>? _closureSub;

  void _init() {
    _isLoading = true;
    notifyListeners();

    // Watch stations from Firestore
    _stationSub = _repo.watchStations().listen(
      (stations) {
        _stations = stations.isEmpty ? _repo.mockStations : stations;
        _isLoading = false;
        _error = null;
        notifyListeners();
        // Load history for selected/most critical station
        _loadHistory();
      },
      onError: (e) {
        // Fall back to mock data on Firestore error (e.g. offline)
        _stations = _repo.mockStations;
        _isLoading = false;
        notifyListeners();
        _loadHistory();
      },
    );

    // Watch flood zones
    _zoneSub = _repo.watchFloodZones().listen(
      (zones) {
        _floodZones = zones.isEmpty ? _repo.mockFloodZones : zones;
        notifyListeners();
      },
      onError: (_) {
        _floodZones = _repo.mockFloodZones;
        notifyListeners();
      },
    );

    // Watch road closures
    _closureSub = _repo.watchRoadClosures().listen(
      (closures) {
        _roadClosures = closures;
        notifyListeners();
      },
      onError: (_) {},
    );
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
        _layers = _layers.copyWith(showFloodZones: !_layers.showFloodZones);
        break;
      case 'stations':
        _layers = _layers.copyWith(showStations: !_layers.showStations);
        break;
      case 'roadClosures':
        _layers = _layers.copyWith(showRoadClosures: !_layers.showRoadClosures);
        break;
      case 'heatmap':
        _layers = _layers.copyWith(showHeatmap: !_layers.showHeatmap);
        break;
    }
    notifyListeners();
  }

  Future<void> reportRoadClosure({
    required LatLng location,
    required String description,
    required String reportedBy,
  }) async {
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
    try {
      await _repo.confirmRoadClosure(closureId);
    } catch (e) {
      print('confirmRoadClosure error: $e');
    }
  }

  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();
    await _loadHistory();
    _isLoading = false;
    notifyListeners();
  }

  void centerOnStation(SensorStation station) {
    _mapCenter = station.location;
    notifyListeners();
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