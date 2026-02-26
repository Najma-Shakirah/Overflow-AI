/*
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'flood_map_viewmodel.dart';

class FloodMapPage extends StatelessWidget {
  const FloodMapPage({super.key});

  static const _initialPosition = CameraPosition(
    target: LatLng(3.1390, 101.6869), // Default: Kuala Lumpur
    zoom: 11,
  );

  @override
  Widget build(BuildContext context) {
    return Consumer<FloodMapViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          body: Stack(
            children: [
              // ── Google Map ─────────────────────────────────────────────
              GoogleMap(
                initialCameraPosition: _initialPosition,
                markers: vm.markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
              ),

              // ── Loading spinner ────────────────────────────────────────
              if (vm.isLoading)
                const Center(child: CircularProgressIndicator()),

              // ── Offline / syncing banner ───────────────────────────────
              if (vm.showOfflineBanner)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: _OfflineBanner(message: vm.offlineBannerMessage),
                  ),
                ),

              // ── Error banner ───────────────────────────────────────────
              if (vm.error != null)
                Positioned(
                  bottom: 80,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade800,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Error: ${vm.error}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),

              // ── Severity legend ────────────────────────────────────────
              const Positioned(
                bottom: 16,
                left: 16,
                child: _SeverityLegend(),
              ),
            ],
          ),

          // ── Report flood FAB ───────────────────────────────────────────
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: Colors.red.shade700,
            icon: const Icon(Icons.add_location_alt, color: Colors.white),
            label: const Text('Report Flood',
                style: TextStyle(color: Colors.white)),
            onPressed: () => _showAddMarkerSheet(context, vm),
          ),
        );
      },
    );
  }

  void _showAddMarkerSheet(BuildContext context, FloodMapViewModel vm) {
    String selectedSeverity = 'low';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFF1A2B45),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              const Text(
                'Report Flood Location',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'This will place a marker at the reported location.',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
              const SizedBox(height: 20),

              // Severity selector
              const Text('Severity Level',
                  style: TextStyle(
                      color: Colors.white70, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Row(
                children: ['low', 'medium', 'high'].map((level) {
                  final isSelected = selectedSeverity == level;
                  final color = level == 'high'
                      ? Colors.red
                      : level == 'medium'
                          ? Colors.orange
                          : Colors.yellow.shade700;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          setModalState(() => selectedSeverity = level),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? color.withOpacity(0.25)
                              : Colors.white.withOpacity(0.05),
                          border: Border.all(
                            color: isSelected ? color : Colors.white24,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          level.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isSelected ? color : Colors.white54,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Offline notice
              if (!vm.isOnline)
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: Colors.orange.withOpacity(0.4)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: Colors.orange, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'You\'re offline. This report will sync to the server automatically when you reconnect.',
                          style:
                              TextStyle(color: Colors.orange, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                    // TODO: replace with the actual tapped lat/lng from map
                    await vm.addFloodMarker(
                      lat: 3.1390,
                      lng: 101.6869,
                      severity: selectedSeverity,
                    );
                  },
                  child: const Text(
                    'Submit Report',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Offline Banner ───────────────────────────────────────────────────────────

class _OfflineBanner extends StatelessWidget {
  final String message;
  const _OfflineBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: message.isEmpty
          ? const SizedBox.shrink()
          : Container(
              key: ValueKey(message),
              margin: const EdgeInsets.all(12),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.orange.shade800,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.wifi_off, color: Colors.white, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// ── Severity Legend ──────────────────────────────────────────────────────────

class _SeverityLegend extends StatelessWidget {
  const _SeverityLegend();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.15), blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Severity',
              style:
                  TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
          const SizedBox(height: 4),
          _LegendRow(color: Colors.yellow.shade700, label: 'Low'),
          _LegendRow(color: Colors.orange, label: 'Medium'),
          _LegendRow(color: Colors.red, label: 'High'),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendRow({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_on, color: color, size: 14),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}
*/