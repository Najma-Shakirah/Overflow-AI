import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../services/ai_service.dart';
import '../navbar/navbar.dart';

class FloodPhotoAnalyserPage extends StatefulWidget {
  const FloodPhotoAnalyserPage({super.key});

  @override
  State<FloodPhotoAnalyserPage> createState() => _FloodPhotoAnalyserPageState();
}

class _FloodPhotoAnalyserPageState extends State<FloodPhotoAnalyserPage> {
  Uint8List? _imageBytes;
  FloodImageAnalysis? _analysis;
  bool _isAnalysing = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    setState(() {
      _imageBytes = bytes;
      _analysis = null;
    });
    _analyseImage(bytes);
  }

  Future<void> _analyseImage(Uint8List bytes) async {
    setState(() => _isAnalysing = true);
    final aiService = context.read<AIService>();
    final result = await aiService.analyseFloodPhoto(bytes);
    setState(() {
      _analysis = result;
      _isAnalysing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: const [
          MonitorFAB(),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
      body: Column(
        children: [
          // --- HEADER matching alerts page style ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF3A83B7), Color.fromARGB(255, 29, 217, 255)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Flood Photo Analyser',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'AI-powered water level & risk assessment',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),

          // --- SCROLLABLE CONTENT ---
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Instructions
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Take or upload a photo of flooded area. AI will assess severity and give safety advice.',
                            style: TextStyle(fontSize: 13, color: Colors.blue[800]),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Image picker buttons
                  Row(
                    children: [
                      Expanded(
                        child: _PickerButton(
                          icon: Icons.camera_alt,
                          label: 'Take Photo',
                          onTap: () => _pickImage(ImageSource.camera),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _PickerButton(
                          icon: Icons.photo_library,
                          label: 'Choose Photo',
                          onTap: () => _pickImage(ImageSource.gallery),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Image preview
                  if (_imageBytes != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.memory(
                        _imageBytes!,
                        width: double.infinity,
                        height: 220,
                        fit: BoxFit.cover,
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Loading indicator
                  if (_isAnalysing)
                    const Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 12),
                          Text('Analysing flood conditions...', 
                               style: TextStyle(fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),

                  // Analysis results
                  if (_analysis != null && !_isAnalysing)
                    _AnalysisResults(analysis: _analysis!),
                  
                  const SizedBox(height: 40), // Bottom padding for scroll
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PickerButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PickerButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF3A83B7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 6),
            Text(label,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _AnalysisResults extends StatelessWidget {
  final FloodImageAnalysis analysis;

  const _AnalysisResults({required this.analysis});

  Color get _severityColor {
    switch (analysis.severity) {
      case 'CRITICAL': return Colors.red;
      case 'HIGH': return Colors.deepOrange;
      case 'MODERATE': return Colors.orange;
      case 'LOW': return Colors.amber;
      default: return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _severityColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _severityColor.withOpacity(0.4), width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    analysis.floodDetected ? Icons.warning_amber : Icons.check_circle,
                    color: _severityColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    analysis.floodDetected ? 'Flood Detected' : 'No Flood Detected',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: _severityColor,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _severityColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      analysis.severity,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(analysis.summary,
                  style: const TextStyle(fontSize: 14, height: 1.4)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.water, size: 16, color: Colors.blue[600]),
                  const SizedBox(width: 4),
                  Text('Est. water level: ${analysis.waterLevel}',
                      style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                  const Spacer(),
                  Icon(
                    analysis.safeToStay ? Icons.home : Icons.directions_run,
                    color: analysis.safeToStay ? Colors.green : Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    analysis.safeToStay ? 'Safe to stay' : 'Evacuate!',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: analysis.safeToStay ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Hazards
        if (analysis.hazards.isNotEmpty) ...[
          const Text('⚠️ Visible Hazards',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),
          ...analysis.hazards.map((h) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(Icons.dangerous_outlined, color: Colors.red[400], size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(h, style: const TextStyle(fontSize: 13))),
                  ],
                ),
              )),
          const SizedBox(height: 16),
        ],

        // Immediate actions
        const Text('✅ Immediate Actions',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 8),
        ...analysis.immediateActions.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3A83B7),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Center(
                      child: Text(
                        '${e.key + 1}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Text(e.value,
                          style: const TextStyle(fontSize: 13, height: 1.4))),
                ],
              ),
            )),
      ],
    );
  }
}