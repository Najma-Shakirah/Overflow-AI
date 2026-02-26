import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../navbar/navbar.dart';
import '../weather/weather_viewmodel.dart';
import '../weather/weather_model.dart';
import '../../services/ai_service.dart';
import '../../widgets/glass_container.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => context.read<WeatherViewModel>().loadWeatherByLocation());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background5.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          // Optional: Gradient overlay for better readability
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF00C6FF).withOpacity(0.3),
                  const Color(0xFF0072FF).withOpacity(0.2),
                ],
              ),
            ),
          ),
          
          // Main Content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Glass Header ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                  child: SafeArea(
                    child: GlassContainer(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, user',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Welcome back!',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Weather + AI Risk Cards ──
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      FloodInfoCard(),
                      SizedBox(height: 14),
                      AIRiskCard(),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Section label: Services ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GlassContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: const Row(
                      children: [
                        Icon(Icons.apps, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Services',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Service Buttons Grid ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GlassContainer(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _GlassServiceButton(
                              icon: Icons.pending_actions,
                              label: 'Checklist',
                              color: Colors.red,
                              routeName: '/checklist',
                            ),
                            _GlassServiceButton(
                              icon: Icons.report,
                              label: 'Report',
                              color: Colors.orange,
                            ),
                            _GlassServiceButton(
                              icon: Icons.house,
                              label: 'Shelters',
                              color: Colors.blue,
                              routeName: '/shelters',
                            ),
                            _GlassServiceButton(
                              icon: Icons.post_add,
                              label: 'Community',
                              color: Colors.green,
                              routeName: '/community',
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _GlassServiceButton(
                              icon: Icons.camera_alt,
                              label: 'Analyse Photo',
                              color: Colors.purple,
                              routeName: '/analyse-photo',
                            ),
                            _GlassServiceButton(
                              icon: Icons.directions_run,
                              label: 'Evacuate',
                              color: Colors.deepOrange,
                              routeName: '/evacuation',
                            ),
                            _GlassServiceButton(
                              icon: Icons.notifications_active,
                              label: 'Alerts',
                              color: Colors.teal,
                              routeName: '/alerts',
                            ),
                            _GlassServiceButton(
                              icon: Icons.videogame_asset,
                              label: 'Games & Tips',
                              color: Colors.indigo,
                              routeName: '/game',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ── Latest Updates ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GlassContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: const Row(
                      children: [
                        Icon(Icons.newspaper, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Latest Updates',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: NewsCarousel(),
                ),

                const SizedBox(height: 120),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: const MonitorFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
    );
  }
}

// ─────────────────────────────────────────────────────────
// GLASS SERVICE BUTTON
// ─────────────────────────────────────────────────────────
class _GlassServiceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final String? routeName;

  const _GlassServiceButton({
    required this.icon,
    required this.label,
    required this.color,
    this.routeName,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (routeName != null) {
          Navigator.pushNamed(context, routeName!);
        }
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withOpacity(0.8),
                  color,
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// WEATHER CARD
// ─────────────────────────────────────────────────────────
class FloodInfoCard extends StatelessWidget {
  const FloodInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WeatherViewModel>();

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: vm.isLoading
          ? const _LoadingWeather()
          : vm.weather != null
              ? _WeatherContent(weather: vm.weather!)
              : _ErrorWeather(
                  error: vm.error,
                  onRetry: () =>
                      context.read<WeatherViewModel>().loadWeatherByLocation(),
                ),
    );
  }
}

class _LoadingWeather extends StatelessWidget {
  const _LoadingWeather();
  @override
  Widget build(BuildContext context) => const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
}

class _ErrorWeather extends StatelessWidget {
  final String? error;
  final VoidCallback onRetry;
  const _ErrorWeather({this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off, color: Colors.white.withOpacity(0.6), size: 32),
          const SizedBox(height: 8),
          Text(error ?? 'Could not load weather',
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
          TextButton(
            onPressed: onRetry,
            child: const Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _WeatherContent extends StatelessWidget {
  final WeatherModel weather;
  const _WeatherContent({required this.weather});

  String get _riskLabel {
    if (weather.rainfall > 10) return 'HIGH';
    if (weather.rainfall > 5) return 'MODERATE';
    return 'LOW';
  }

  Color get _riskColor {
    if (weather.rainfall > 10) return Colors.red;
    if (weather.rainfall > 5) return Colors.orange;
    return Colors.green;
  }

  double get _riskFactor {
    if (weather.rainfall > 10) return 0.9;
    if (weather.rainfall > 5) return 0.6;
    return 0.2;
  }

  IconData get _weatherIcon {
    final c = weather.condition.toLowerCase();
    if (c.contains('rain') || c.contains('drizzle')) return Icons.grain;
    if (c.contains('thunder')) return Icons.thunderstorm;
    if (c.contains('cloud')) return Icons.cloud_queue;
    if (c.contains('clear')) return Icons.wb_sunny;
    return Icons.cloud_queue;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Temp + location + icon
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${weather.temperature.toStringAsFixed(0)}°',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Icon(Icons.water_drop,
                          color: Colors.white.withOpacity(0.8), size: 20),
                    ),
                  ],
                ),
                Text(weather.location,
                    style: const TextStyle(fontSize: 14, color: Colors.white70)),
                Text(weather.condition,
                    style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.6))),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_weatherIcon, color: Colors.white, size: 32),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Flood risk row
        Row(
          children: [
            const Text('Flood Risk: ',
                style: TextStyle(fontSize: 13, color: Colors.white70)),
            Text(_riskLabel,
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.bold, color: _riskColor)),
            const Spacer(),
            Icon(Icons.speed, color: _riskColor, size: 18),
          ],
        ),
        const SizedBox(height: 6),

        // Risk bar
        Stack(
          children: [
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            FractionallySizedBox(
              widthFactor: _riskFactor,
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _riskFactor > 0.7
                        ? [Colors.orange, Colors.red]
                        : [Colors.green, Colors.yellow, Colors.orange],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Stats row
        Row(
          children: [
            Expanded(
              child: _StatItem(
                icon: Icons.water,
                label: 'Rainfall',
                value: '${weather.rainfall.toStringAsFixed(1)}mm',
              ),
            ),
            Expanded(
              child: _StatItem(
                icon: Icons.water_drop_outlined,
                label: 'Humidity',
                value: '${weather.humidity.toInt()}%',
              ),
            ),
            Expanded(
              child: _StatItem(
                icon: Icons.air,
                label: 'Wind',
                value: '${weather.windSpeed.toStringAsFixed(1)}m/s',
              ),
            ),
            Expanded(
              child: _StatItem(
                icon: Icons.thermostat,
                label: 'Feels',
                value: '${weather.feelsLike.toStringAsFixed(0)}°C',
              ),
            ),
          ],
        ),

        // Flood warning banner
        if (weather.isFloodRisk) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.red.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.red[300], size: 18),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    '⚠️ High rainfall detected — flood risk in your area',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white)),
        Text(label,
            style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.7))),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
// AI RISK CARD
// ─────────────────────────────────────────────────────────
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _runAnalysis());
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

    if (mounted) {
      setState(() {
        _analysis = result;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final weather = context.watch<WeatherViewModel>().weather;
    if (weather == null && !_isLoading) return const SizedBox.shrink();

    if (_isLoading) {
      return GlassContainer(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Text('AI analysing flood risk...',
                style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.8))),
          ],
        ),
      );
    }

    if (_analysis == null) return const SizedBox.shrink();

    final a = _analysis!;

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: a.riskColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.smart_toy, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text('AI Flood Risk Analysis',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: a.riskColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    a.riskLevel,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: Colors.white70,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Risk score bar
            Row(
              children: [
                Text('Risk score: ${a.riskScore}/100',
                    style: const TextStyle(fontSize: 12, color: Colors.white70)),
                const SizedBox(width: 10),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: a.riskScore / 100,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(a.riskColor),
                      minHeight: 6,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Text(a.summary, style: const TextStyle(fontSize: 13, height: 1.4, color: Colors.white)),

            // Expanded details
            if (_expanded) ...[
              const SizedBox(height: 14),
              Divider(color: Colors.white.withOpacity(0.3)),
              const SizedBox(height: 10),

              const Text('📅 Forecast',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
              const SizedBox(height: 6),
              Text(a.forecast,
                  style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.9), height: 1.4)),

              if (a.riskFactors.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text('⚠️ Risk Factors',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                const SizedBox(height: 6),
                ...a.riskFactors.map((f) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.circle, size: 6, color: a.riskColor),
                          const SizedBox(width: 8),
                          Expanded(
                              child: Text(f, style: const TextStyle(fontSize: 12, color: Colors.white))),
                        ],
                      ),
                    )),
              ],

              if (a.recommendations.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text('✅ Recommendations',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                const SizedBox(height: 6),
                ...a.recommendations.map((r) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle_outline, size: 16, color: Colors.white70),
                          const SizedBox(width: 8),
                          Expanded(
                              child: Text(r,
                                  style: const TextStyle(fontSize: 12, height: 1.3, color: Colors.white))),
                        ],
                      ),
                    )),
              ],

              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _runAnalysis,
                  icon: const Icon(Icons.refresh, size: 14, color: Colors.white),
                  label: const Text('Refresh', style: TextStyle(fontSize: 12, color: Colors.white)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// NEWS CAROUSEL
// ─────────────────────────────────────────────────────────
class NewsCarousel extends StatefulWidget {
  const NewsCarousel({super.key});

  @override
  State<NewsCarousel> createState() => _NewsCarouselState();
}

class _NewsCarouselState extends State<NewsCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_NewsItem> _newsItems = [
    _NewsItem(
      title: 'Emergency Services on High Alert',
      description: 'Rescue teams deployed across 12 affected areas in Kuala Lumpur',
      time: '15 mins ago',
      category: 'Emergency',
      categoryColor: Colors.red,
    ),
    _NewsItem(
      title: 'Water Levels Rising in Klang Valley',
      description: 'Authorities warn residents to stay vigilant as rainfall continues',
      time: '1 hour ago',
      category: 'Warning',
      categoryColor: Colors.orange,
    ),
    _NewsItem(
      title: 'Relief Centers Opened',
      description: '8 temporary shelters now available for displaced residents',
      time: '2 hours ago',
      category: 'Relief',
      categoryColor: Colors.blue,
    ),
    _NewsItem(
      title: 'Road Closures Updated',
      description: 'Major highways affected — check latest route information',
      time: '3 hours ago',
      category: 'Traffic',
      categoryColor: Colors.purple,
    ),
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), _autoScroll);
  }

  void _autoScroll() {
    if (!mounted) return;
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      final next = (_currentPage + 1) % _newsItems.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
      _autoScroll();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 140,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: _newsItems.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _NewsCard(item: _newsItems[index]),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _newsItems.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == i ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPage == i ? Colors.white : Colors.white.withOpacity(0.4),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NewsItem {
  final String title;
  final String description;
  final String time;
  final String category;
  final Color categoryColor;

  _NewsItem({
    required this.title,
    required this.description,
    required this.time,
    required this.category,
    required this.categoryColor,
  });
}

class _NewsCard extends StatelessWidget {
  final _NewsItem item;
  const _NewsCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: item.categoryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item.category.toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
              const Spacer(),
              Icon(Icons.access_time, size: 14, color: Colors.white70),
              const SizedBox(width: 4),
              Text(item.time, style: const TextStyle(fontSize: 12, color: Colors.white70)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            item.description,
            style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.9), height: 1.3),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}