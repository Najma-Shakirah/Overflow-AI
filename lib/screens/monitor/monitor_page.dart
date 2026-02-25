// lib/screens/monitor/monitor_page.dart
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'monitor_model.dart';
import 'monitor_viewmodel.dart';

class MonitorPage extends StatelessWidget {
  const MonitorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MonitorViewModel(),
      child: const _MonitorView(),
    );
  }
}

class _MonitorView extends StatefulWidget {
  const _MonitorView();

  @override
  State<_MonitorView> createState() => _MonitorViewState();
}

class _MonitorViewState extends State<_MonitorView>
    with SingleTickerProviderStateMixin {
  late final MapController _mapController;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _mapController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MonitorViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          // ── Header ────────────────────────────────────────────────────
          _Header(vm: vm),

          // ── Situation banner ──────────────────────────────────────────
          if (!vm.isLoading) _SituationBanner(vm: vm),

          // ── Tab bar ───────────────────────────────────────────────────
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF3A83B7),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFF3A83B7),
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'Map'),
                Tab(text: 'Stations'),
                Tab(text: 'Road Closures'),
              ],
            ),
          ),

          // ── Tab views ─────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _MapTab(mapController: _mapController, vm: vm),
                _StationsTab(vm: vm),
                _RoadClosuresTab(vm: vm),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final MonitorViewModel vm;
  const _Header({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3A83B7), Color.fromARGB(255, 29, 255, 142)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Live Monitoring',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                            color: Colors.greenAccent,
                            shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        vm.isLoading
                            ? 'Loading...'
                            : 'Live • ${vm.stations.length} stations active',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Quick stats chips
            if (!vm.isLoading) ...[
              _HeaderChip(
                  count: vm.dangerStationCount,
                  label: 'Danger',
                  color: Colors.red),
              const SizedBox(width: 6),
              _HeaderChip(
                  count: vm.warningStationCount,
                  label: 'Warning',
                  color: Colors.orange),
            ],
          ],
        ),
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  final int count;
  final String label;
  final Color color;
  const _HeaderChip(
      {required this.count, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white30),
      ),
      child: Row(
        children: [
          Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text('$count $label',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ─── Situation Banner ─────────────────────────────────────────────────────────
class _SituationBanner extends StatelessWidget {
  final MonitorViewModel vm;
  const _SituationBanner({required this.vm});

  @override
  Widget build(BuildContext context) {
    if (vm.overallSituation == FloodSituation.normal) {
      return const SizedBox.shrink();
    }

    final isDanger = vm.overallSituation == FloodSituation.danger;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: isDanger ? Colors.red[700] : Colors.orange[700],
      child: Row(
        children: [
          const Icon(Icons.warning_amber, color: Colors.white, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isDanger
                  ? '⚠️ ${vm.dangerStationCount} station(s) at DANGER level — check map immediately'
                  : '${vm.warningStationCount} station(s) approaching warning level',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── MAP TAB ─────────────────────────────────────────────────────────────────
class _MapTab extends StatelessWidget {
  final MapController mapController;
  final MonitorViewModel vm;
  const _MapTab({required this.mapController, required this.vm});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── Flutter Map ──────────────────────────────────────────────
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: vm.mapCenter,
            initialZoom: 12.5,
            onTap: (_, __) => vm.clearSelectedStation(),
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c'],
            ),

            // Flood zone polygons
            if (vm.layers.showFloodZones)
              PolygonLayer(
                polygons: vm.floodZones
                    .map((z) => Polygon(
                          points: z.points,
                          color: z.fillColor,
                          borderColor: z.borderColor,
                          borderStrokeWidth: 2,
                        ))
                    .toList(),
              ),

            // Road closure markers
            if (vm.layers.showRoadClosures)
              MarkerLayer(
                markers: vm.roadClosures
                    .map((c) => Marker(
                          point: c.location,
                          width: 36,
                          height: 36,
                          child: GestureDetector(
                            onTap: () =>
                                _showRoadClosureSheet(context, c, vm),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white, width: 2),
                              ),
                              child: const Icon(Icons.block,
                                  color: Colors.white, size: 18),
                            ),
                          ),
                        ))
                    .toList(),
              ),

            // Sensor station markers
            if (vm.layers.showStations)
              MarkerLayer(
                markers: vm.stations
                    .map((s) => Marker(
                          point: s.location,
                          width: 44,
                          height: 44,
                          child: GestureDetector(
                            onTap: () => vm.selectStation(s),
                            child: _StationMapMarker(station: s),
                          ),
                        ))
                    .toList(),
              ),
          ],
        ),

        // ── Layer toggles (top-right) ────────────────────────────────
        Positioned(
          top: 12,
          right: 12,
          child: _LayerToggles(vm: vm),
        ),

        // ── Zoom to location button ──────────────────────────────────
        Positioned(
          bottom: 120,
          right: 12,
          child: FloatingActionButton.small(
            heroTag: 'zoom',
            backgroundColor: Colors.white,
            onPressed: () {
              mapController.move(const LatLng(3.1390, 101.6869), 12.5);
            },
            child: const Icon(Icons.my_location,
                color: Color(0xFF3A83B7)),
          ),
        ),

        // ── Report road closure button ───────────────────────────────
        Positioned(
          bottom: 60,
          right: 12,
          child: FloatingActionButton.small(
            heroTag: 'closure',
            backgroundColor: Colors.red,
            onPressed: () => _showReportClosureSheet(context, vm),
            child: const Icon(Icons.add_road, color: Colors.white),
          ),
        ),

        // ── Selected station bottom sheet ────────────────────────────
        if (vm.selectedStation != null)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _SelectedStationCard(
              station: vm.selectedStation!,
              history: vm.waterHistory,
              vm: vm,
            ),
          ),

        // ── Loading overlay ──────────────────────────────────────────
        if (vm.isLoading)
          Container(
            color: Colors.black26,
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  void _showRoadClosureSheet(
      BuildContext context, RoadClosure closure, MonitorViewModel vm) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.block, color: Colors.red),
                const SizedBox(width: 10),
                const Text('Road Closure',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const Spacer(),
                if (closure.isVerified)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Verified',
                        style: TextStyle(
                            color: Colors.white, fontSize: 11)),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(closure.description),
            const SizedBox(height: 6),
            Text('Reported ${closure.timeAgo} by ${closure.reportedBy}',
                style:
                    TextStyle(fontSize: 12, color: Colors.grey[500])),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.thumb_up_outlined,
                    color: Colors.grey[400], size: 16),
                const SizedBox(width: 6),
                Text('${closure.confirmedCount} people confirmed this',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey[500])),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    vm.confirmRoadClosure(closure.id);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3A83B7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Confirm'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showReportClosureSheet(BuildContext context, MonitorViewModel vm) {
    final descController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Report Road Closure',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 17)),
            const SizedBox(height: 6),
            Text(
              'Your current map center location will be used.',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText:
                    'Describe the situation e.g. "Road flooded, 1m water, cars cannot pass"',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (descController.text.trim().isEmpty) return;
                  Navigator.pop(context);
                  await vm.reportRoadClosure(
                    location: vm.mapCenter,
                    description: descController.text.trim(),
                    reportedBy: 'Anonymous',
                  );
                },
                icon: const Icon(Icons.send),
                label: const Text('Submit Report'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StationMapMarker extends StatelessWidget {
  final SensorStation station;
  const _StationMapMarker({required this.station});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: station.statusColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
              color: station.statusColor.withOpacity(0.4),
              blurRadius: 6,
              spreadRadius: 1),
        ],
      ),
      child: const Icon(Icons.sensors, color: Colors.white, size: 22),
    );
  }
}

class _LayerToggles extends StatelessWidget {
  final MonitorViewModel vm;
  const _LayerToggles({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          _LayerToggleBtn(
            icon: Icons.layers,
            label: 'Zones',
            active: vm.layers.showFloodZones,
            color: Colors.red,
            onTap: () => vm.toggleLayer('floodZones'),
          ),
          const SizedBox(height: 6),
          _LayerToggleBtn(
            icon: Icons.sensors,
            label: 'Stations',
            active: vm.layers.showStations,
            color: Colors.blue,
            onTap: () => vm.toggleLayer('stations'),
          ),
          const SizedBox(height: 6),
          _LayerToggleBtn(
            icon: Icons.block,
            label: 'Closures',
            active: vm.layers.showRoadClosures,
            color: Colors.orange,
            onTap: () => vm.toggleLayer('roadClosures'),
          ),
        ],
      ),
    );
  }
}

class _LayerToggleBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final Color color;
  final VoidCallback onTap;

  const _LayerToggleBtn({
    required this.icon,
    required this.label,
    required this.active,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: active ? color.withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: active ? color : Colors.grey),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    color: active ? color : Colors.grey,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// ─── Selected Station Card (bottom of map) ────────────────────────────────────
class _SelectedStationCard extends StatelessWidget {
  final SensorStation station;
  final List<WaterLevelPoint> history;
  final MonitorViewModel vm;

  const _SelectedStationCard({
    required this.station,
    required this.history,
    required this.vm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 16,
              offset: const Offset(0, -4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: station.statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                    Icon(Icons.sensors, color: station.statusColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(station.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(station.river,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey[500])),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${station.waterLevel.toStringAsFixed(1)}m',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: station.statusColor),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: station.statusColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      station.statusLabel,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Water level progress bar
          Row(
            children: [
              Text('0m',
                  style: TextStyle(fontSize: 10, color: Colors.grey[400])),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Stack(
                    children: [
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      // Warning marker
                      FractionallySizedBox(
                        widthFactor:
                            station.warningLevel / station.dangerLevel,
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      // Actual level
                      FractionallySizedBox(
                        widthFactor: station.levelFraction,
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: station.statusColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Text('${station.dangerLevel}m',
                  style:
                      TextStyle(fontSize: 10, color: Colors.grey[400])),
            ],
          ),
          const SizedBox(height: 12),

          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MiniStat(
                  icon: Icons.speed,
                  label: 'Flow',
                  value: '${station.flowRate.toStringAsFixed(0)} m³/s',
                  color: Colors.indigo),
              _MiniStat(
                  icon: Icons.water_drop,
                  label: 'Rainfall',
                  value: '${station.rainfall.toStringAsFixed(1)} mm/hr',
                  color: Colors.cyan),
              _MiniStat(
                  icon: Icons.access_time,
                  label: 'Updated',
                  value: station.lastUpdatedLabel,
                  color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _MiniStat(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(height: 3),
        Text(value,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color)),
        Text(label,
            style: TextStyle(fontSize: 10, color: Colors.grey[500])),
      ],
    );
  }
}

// ─── STATIONS TAB ─────────────────────────────────────────────────────────────
class _StationsTab extends StatelessWidget {
  final MonitorViewModel vm;
  const _StationsTab({required this.vm});

  @override
  Widget build(BuildContext context) {
    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: vm.refresh,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary row
          _SummaryRow(vm: vm),
          const SizedBox(height: 16),

          // Water level graph for selected/critical station
          if (vm.waterHistory.isNotEmpty) ...[
            _WaterLevelGraph(
              history: vm.waterHistory,
              station: vm.selectedStation ?? vm.mostCriticalStation,
            ),
            const SizedBox(height: 16),
          ],

          // Station cards
          const Text('Active Stations',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF2D3748))),
          const SizedBox(height: 10),
          ...vm.stations.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _StationCard(
                  station: s,
                  isSelected:
                      vm.selectedStation?.id == s.id,
                  onTap: () => vm.selectStation(s),
                ),
              )),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final MonitorViewModel vm;
  const _SummaryRow({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            value: '${vm.stations.length}',
            label: 'Stations',
            icon: Icons.sensors,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryCard(
            value: '${vm.dangerStationCount}',
            label: 'Danger',
            icon: Icons.warning,
            color: Colors.red,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryCard(
            value: '${vm.warningStationCount}',
            label: 'Warning',
            icon: Icons.warning_amber,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryCard(
            value: '${vm.activeRoadClosures}',
            label: 'Closures',
            icon: Icons.block,
            color: Colors.purple,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  const _SummaryCard(
      {required this.value,
      required this.label,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: color)),
          Text(label,
              style:
                  TextStyle(fontSize: 10, color: Colors.grey[500])),
        ],
      ),
    );
  }
}

class _StationCard extends StatelessWidget {
  final SensorStation station;
  final bool isSelected;
  final VoidCallback onTap;
  const _StationCard(
      {required this.station,
      required this.isSelected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? station.statusColor
                : station.statusColor.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: station.statusColor.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: station.statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.sensors,
                  color: station.statusColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(station.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(station.river,
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey[500])),
                  const SizedBox(height: 6),
                  // Level bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: station.levelFraction,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                          station.statusColor),
                      minHeight: 5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                              color: station.statusColor,
                              shape: BoxShape.circle)),
                      const SizedBox(width: 4),
                      Text(station.statusLabel,
                          style: TextStyle(
                              fontSize: 11,
                              color: station.statusColor,
                              fontWeight: FontWeight.w600)),
                      Text(' • ${station.lastUpdatedLabel}',
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey[500])),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${station.waterLevel.toStringAsFixed(1)}m',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: station.statusColor)),
                Text('Water Level',
                    style: TextStyle(
                        fontSize: 10, color: Colors.grey[500])),
                const SizedBox(height: 6),
                Text(
                    '${station.rainfall.toStringAsFixed(0)}mm/hr',
                    style: TextStyle(
                        fontSize: 11, color: Colors.cyan[700])),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Water Level Graph ────────────────────────────────────────────────────────
class _WaterLevelGraph extends StatelessWidget {
  final List<WaterLevelPoint> history;
  final SensorStation? station;
  const _WaterLevelGraph({required this.history, this.station});

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) return const SizedBox.shrink();

    final maxLevel = history
        .map((p) => p.level)
        .reduce((a, b) => a > b ? a : b);
    final dangerLevel = station?.dangerLevel ?? 4.5;
    final warningLevel = station?.warningLevel ?? 3.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                station != null
                    ? '${station!.name} — 24h Trend'
                    : 'Water Level — 24h Trend',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Text('max ${maxLevel.toStringAsFixed(1)}m',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500])),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: CustomPaint(
              size: const Size(double.infinity, 120),
              painter: _GraphPainter(
                points: history,
                warningLevel: warningLevel,
                dangerLevel: dangerLevel,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _GraphLegend(color: Colors.blue, label: 'Water Level'),
              _GraphLegend(
                  color: Colors.orange, label: 'Warning ${warningLevel}m'),
              _GraphLegend(
                  color: Colors.red, label: 'Danger ${dangerLevel}m'),
            ],
          ),
        ],
      ),
    );
  }
}

class _GraphLegend extends StatelessWidget {
  final Color color;
  final String label;
  const _GraphLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 12,
            height: 4,
            decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 5),
        Text(label,
            style: TextStyle(fontSize: 10, color: Colors.grey[600])),
      ],
    );
  }
}

class _GraphPainter extends CustomPainter {
  final List<WaterLevelPoint> points;
  final double warningLevel;
  final double dangerLevel;

  const _GraphPainter({
    required this.points,
    required this.warningLevel,
    required this.dangerLevel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final maxVal = dangerLevel + 0.5;
    double toY(double val) =>
        size.height - (val / maxVal * size.height).clamp(0, size.height);

    // Draw danger line
    final dangerPaint = Paint()
      ..color = Colors.red.withOpacity(0.5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final dangerY = toY(dangerLevel);
    canvas.drawLine(
        Offset(0, dangerY), Offset(size.width, dangerY), dangerPaint);

    // Draw warning line
    final warningPaint = Paint()
      ..color = Colors.orange.withOpacity(0.5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final warningY = toY(warningLevel);
    canvas.drawLine(
        Offset(0, warningY), Offset(size.width, warningY), warningPaint);

    // Draw water level line
    final linePaint = Paint()
      ..color = const Color(0xFF3A83B7)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = const Color(0xFF3A83B7).withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final path = ui.Path();
    final fillPath = ui.Path();

    for (int i = 0; i < points.length; i++) {
      final x = size.width * i / (points.length - 1);
      final y = toY(points[i].level);
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _GraphPainter old) =>
      old.points != points;
}

// ─── ROAD CLOSURES TAB ───────────────────────────────────────────────────────
class _RoadClosuresTab extends StatelessWidget {
  final MonitorViewModel vm;
  const _RoadClosuresTab({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Report button banner
        Container(
          width: double.infinity,
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Row(
            children: [
              const Icon(Icons.add_road, color: Colors.red),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Know of a flooded road? Report it to warn others.',
                  style:
                      TextStyle(fontSize: 13, color: Colors.red[700]),
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to Map tab and open sheet
                  // (handled in MapTab directly)
                },
                child: const Text('Go to Map',
                    style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),

        if (vm.roadClosures.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline,
                      color: Colors.green[400], size: 52),
                  const SizedBox(height: 12),
                  const Text('No road closures reported',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('All roads appear to be passable',
                      style: TextStyle(
                          color: Colors.grey[500], fontSize: 13)),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16),
              itemCount: vm.roadClosures.length,
              itemBuilder: (_, i) {
                final c = vm.roadClosures[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade100),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.block,
                            color: Colors.red, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.description,
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text(
                              '${c.timeAgo} • ${c.reportedBy} • ${c.confirmedCount} confirmed',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      ),
                      if (c.isVerified)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('✓',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11)),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}