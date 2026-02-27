// lib/screens/home/ai_risk_card.dart
// Drop this widget inside home_page.dart below FloodInfoCard

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/ai_service.dart';
import '../weather/weather_viewmodel.dart';

class AIRiskCard extends StatefulWidget {
  const AIRiskCard({super.key});

  @override
  State<AIRiskCard> createState() => _AIRiskCardState();
}

class _AIRiskCardState extends State<AIRiskCard> {
  FloodRiskAnalysis? _analysis;
  bool _isLoading = false;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _runAnalysis();
  }

  Future<void> _runAnalysis() async {
    final weather = context.read<WeatherViewModel>().weather;
    if (weather == null) return;

    setState(() => _isLoading = true);

    final ai = context.read<AIService>();
    final result = await ai.analyseFloodRisk(
      location: weather.location,
      temperature: weather.temperature,
      rainfall: weather.rainfall,
      humidity: weather.humidity,
      windSpeed: weather.windSpeed,
    );

    setState(() {
      _analysis = result;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.56),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('AI analysing flood risk...',
                style: TextStyle(fontSize: 13, color: Colors.grey)),
          ],
        ),
      );
    }

    if (_analysis == null) return const SizedBox.shrink();

    final a = _analysis!;

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: a.riskColor.withOpacity(0.4), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: a.riskColor.withOpacity(1.0),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: a.riskColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.smart_toy,
                      color: a.riskColor, size: 20),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'AI Flood Risk Analysis',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: a.riskColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    a.riskLevel,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.grey,
                  size: 20,
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Risk score bar
            Row(
              children: [
                Text('Risk score: ${a.riskScore}/100',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey[600])),
                const SizedBox(width: 10),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: a.riskScore / 100,
                      backgroundColor: Colors.grey[200],
                      valueColor:
                          AlwaysStoppedAnimation<Color>(a.riskColor),
                      minHeight: 6,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),
            Text(a.summary,
                style:
                    const TextStyle(fontSize: 13, height: 1.4)),

            // Expanded details
            if (_expanded) ...[
              const SizedBox(height: 14),
              const Divider(),
              const SizedBox(height: 10),

              // Forecast
              const Text('📅 Forecast',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              Text(a.forecast,
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                      height: 1.4)),

              const SizedBox(height: 12),

              // Risk factors
              if (a.riskFactors.isNotEmpty) ...[
                const Text('⚠️ Risk Factors',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                ...a.riskFactors.map((f) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.circle,
                              size: 6,
                              color: a.riskColor),
                          const SizedBox(width: 8),
                          Expanded(
                              child: Text(f,
                                  style: const TextStyle(
                                      fontSize: 12))),
                        ],
                      ),
                    )),
                const SizedBox(height: 12),
              ],

              // Recommendations
              if (a.recommendations.isNotEmpty) ...[
                const Text('✅ Recommendations',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                ...a.recommendations.map((r) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle_outline,
                              size: 16,
                              color: Color(0xFF3A83B7)),
                          const SizedBox(width: 8),
                          Expanded(
                              child: Text(r,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      height: 1.3))),
                        ],
                      ),
                    )),
              ],

              const SizedBox(height: 8),
              // Regenerate
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _runAnalysis,
                  icon: const Icon(Icons.refresh, size: 14),
                  label: const Text('Refresh',
                      style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}