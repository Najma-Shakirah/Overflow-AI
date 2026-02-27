// lib/screens/ai/evacuation_plan_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/ai_service.dart';
import '../weather/weather_viewmodel.dart';

class EvacuationPlanPage extends StatefulWidget {
  const EvacuationPlanPage({super.key});

  @override
  State<EvacuationPlanPage> createState() => _EvacuationPlanPageState();
}

class _EvacuationPlanPageState extends State<EvacuationPlanPage> {
  EvacuationPlan? _plan;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _generatePlan();
  }

  Future<void> _generatePlan() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final weather = context.read<WeatherViewModel>().weather;
    if (weather == null) {
      setState(() {
        _error = 'Weather data unavailable. Cannot generate evacuation plan.';
        _isLoading = false;
      });
      return;
    }

    final aiService = context.read<AIService>();
    final plan = await aiService.getEvacuationPlan(
      location: weather.location,
      severity: weather.isFloodRisk ? 'HIGH' : 'LOW',
      rainfall: weather.rainfall,
      waterLevel: weather.rainfall / 10, // estimate
    );

    setState(() {
      _plan = plan;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Evacuation Plan'),
        backgroundColor: const Color(0xFF3A83B7),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _generatePlan,
            tooltip: 'Regenerate',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Generating evacuation plan...'),
                ],
              ),
            )
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.red, size: 48),
                        const SizedBox(height: 12),
                        Text(_error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 14)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _generatePlan,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : _plan != null
                  ? _PlanContent(plan: _plan!, onRegenerate: _generatePlan)
                  : const SizedBox.shrink(),
    );
  }
}

class _PlanContent extends StatelessWidget {
  final EvacuationPlan plan;
  final VoidCallback onRegenerate;

  const _PlanContent({required this.plan, required this.onRegenerate});

  Color get _urgencyColor {
    switch (plan.urgency) {
      case 'IMMEDIATE':
        return Colors.red;
      case 'SOON':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Urgency banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _urgencyColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      plan.evacuateNow
                          ? Icons.directions_run
                          : Icons.visibility,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      plan.evacuateNow ? 'EVACUATE NOW' : 'Stay Alert',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  plan.timeframe,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Text(
                  plan.summary,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 14, height: 1.4),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Emergency number
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.phone, color: Colors.red),
                const SizedBox(width: 10),
                Text(
                  'Emergency: Call ${plan.callIfNeeded}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Evacuation routes
          if (plan.routes.isNotEmpty) ...[
            const Text('🗺️ Evacuation Routes',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            ...plan.routes.map((route) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.arrow_forward,
                              color: Color(0xFF3A83B7), size: 18),
                          const SizedBox(width: 6),
                          Text(
                            route['direction'] ?? '',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                      if (route['landmark'] != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on,
                                size: 14, color: Colors.grey[500]),
                            const SizedBox(width: 4),
                            Text(route['landmark']!,
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[600])),
                          ],
                        ),
                      ],
                      if (route['reason'] != null) ...[
                        const SizedBox(height: 4),
                        Text(route['reason']!,
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[700])),
                      ],
                    ],
                  ),
                )),
            const SizedBox(height: 16),
          ],

          // Assembly points
          if (plan.assemblyPoints.isNotEmpty) ...[
            const Text('🏫 Assembly Points / Shelters',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            ...plan.assemblyPoints.map((point) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.house,
                          color: Color(0xFF3A83B7), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(point,
                              style: const TextStyle(fontSize: 13))),
                    ],
                  ),
                )),
            const SizedBox(height: 16),
          ],

          // What to bring
          if (plan.whatToBring.isNotEmpty) ...[
            const Text('🎒 What to Bring',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: plan.whatToBring
                  .map((item) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3A83B7).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: const Color(0xFF3A83B7).withOpacity(0.3)),
                        ),
                        child: Text(item,
                            style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF3A83B7),
                                fontWeight: FontWeight.w500)),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/checklist'),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.pending_actions,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'View Full Checklist',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.orange,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'See all essential items to prepare',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.orange),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 30),

          // Regenerate button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onRegenerate,
              icon: const Icon(Icons.refresh),
              label: const Text('Regenerate Plan'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
