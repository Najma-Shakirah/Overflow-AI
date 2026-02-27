import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../navbar/navbar.dart';
import '../weather/weather_viewmodel.dart';
import '../weather/weather_model.dart';
import '../../services/ai_service.dart';
import '../../widgets/glass_container.dart';
import '../authentication/auth_viewmodel.dart';

class _C {
  static const heading    = Color(0xFF1E1B4B);
  static const body       = Color(0xFF3B0764);
  static const muted      = Color(0xFF312E81);
  static const accent     = Color(0xFF1E3A8A);
  static const purple     = Color(0xFF4C1D95);
  static const riskLow    = Color.fromARGB(255, 0, 201, 80);
  static const riskMod    = Color.fromARGB(255, 210, 77, 0);
  static const riskHigh   = Color.fromARGB(255, 206, 0, 0);
  static const riskLowBg  = Color.fromARGB(205, 202, 255, 216);
  static const riskModBg  = Color.fromARGB(181, 255, 232, 193);
  static const riskHighBg = Color.fromARGB(143, 255, 194, 194);
  static const emergency  = Color.fromARGB(255, 255, 21, 21);
  static const warning    = Color.fromARGB(255, 255, 107, 21);
  static const relief     = Color.fromARGB(255, 42, 99, 255);
  static const traffic    = Color.fromARGB(255, 194, 145, 0);
}

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
    final authVM = context.watch<AuthViewModel>();
    // displayName resolves to: fullName (registered) | 'Guest' (anonymous) | 'there' (loading)
    final String displayName = authVM.displayName;

    return Scaffold(
      body: Stack(
        children: [
          // ── Background image ──
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background5.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // ── Gradient overlay ──
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF00C6FF).withOpacity(0.35),
                  const Color(0xFF0072FF).withOpacity(0.25),
                ],
              ),
            ),
          ),

          // ── Main Content ──
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  // ── Hero header ──
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, $displayName',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                  shadows: const [
                                    Shadow(
                                      color: Color(0xAA000000),
                                      blurRadius: 10,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Welcome back!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              shadows: [
                                Shadow(
                                  color: Color(0x99000000),
                                  blurRadius: 8,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                    ],
                  ),

                  const SizedBox(height: 28),

                  const FloodInfoCard(),
                  const SizedBox(height: 14),
                  const AIRiskCard(),

                  const SizedBox(height: 32),

                  const _SectionLabel(
                      icon: Icons.apps_rounded, title: 'Services'),
                  const SizedBox(height: 16),
                  const _ServicesGrid(),

                  const SizedBox(height: 32),

                  const _SectionLabel(
                      icon: Icons.newspaper_rounded,
                      title: 'Latest Updates'),
                  const SizedBox(height: 16),
                  const NewsCarousel(),

                  const SizedBox(height: 120),
                ],
              ),
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
// SECTION LABEL
// ─────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionLabel({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color.fromARGB(255, 255, 255, 255), size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 255, 255, 255),
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
// SERVICES GRID
// ─────────────────────────────────────────────────────────
class _ServicesGrid extends StatelessWidget {
  const _ServicesGrid();

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ServiceButton(icon: Icons.medical_services_rounded, label: 'Get Help',         color: const Color.fromARGB(255, 255, 33, 33), routeName: '/help'),
              _ServiceButton(icon: Icons.groups_rounded,          label: 'Community', color: const Color.fromARGB(255, 0, 185, 68), routeName: '/community'),
              _ServiceButton(icon: Icons.camera_alt_rounded,           label: 'Analyse Photo', color: const Color(0xFF9333EA), routeName: '/analyse-photo'),

            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ServiceButton(icon: Icons.directions_run_rounded,       label: 'Evacuate',       color: const Color(0xFFEA580C), routeName: '/evacuation'),
              _ServiceButton(icon: Icons.home_rounded,            label: 'Shelters',  color: const Color.fromARGB(255, 53, 151, 255), routeName: '/shelters'),
              _ServiceButton(icon: Icons.videogame_asset_rounded,      label: 'Games & Tips',  color: const Color(0xFF4F46E5), routeName: '/gamedashboard'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ServiceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final String? routeName;

  const _ServiceButton({
    required this.icon,
    required this.label,
    required this.color,
    this.routeName,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (routeName != null) Navigator.pushNamed(context, routeName!);
      },
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color.withOpacity(0.85), color],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: _C.heading,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
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
      padding: const EdgeInsets.all(20),
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
        child: Center(child: CircularProgressIndicator(color: _C.heading)),
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
          const Icon(Icons.cloud_off, color: _C.muted, size: 32),
          const SizedBox(height: 8),
          Text(error ?? 'Could not load weather',
              style: const TextStyle(color: _C.body, fontSize: 13)),
          TextButton(
            onPressed: onRetry,
            child: const Text('Retry', style: TextStyle(color: _C.accent)),
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
    if (weather.rainfall > 5)  return 'MODERATE';
    return 'LOW';
  }

  Color get _riskColor {
    if (weather.rainfall > 10) return _C.riskHigh;
    if (weather.rainfall > 5)  return _C.riskMod;
    return _C.riskLow;
  }

  Color get _riskBg {
    if (weather.rainfall > 10) return _C.riskHighBg;
    if (weather.rainfall > 5)  return _C.riskModBg;
    return _C.riskLowBg;
  }

  double get _riskFactor {
    if (weather.rainfall > 10) return 0.9;
    if (weather.rainfall > 5)  return 0.6;
    return 0.2;
  }

  IconData get _weatherIcon {
    final c = weather.condition.toLowerCase();
    if (c.contains('rain') || c.contains('drizzle')) return Icons.grain;
    if (c.contains('thunder')) return Icons.thunderstorm;
    if (c.contains('cloud'))   return Icons.cloud_queue;
    if (c.contains('clear'))   return Icons.wb_sunny;
    return Icons.cloud_queue;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: _C.heading,
                        height: 1.0,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Icon(Icons.water_drop, color: _C.accent, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(weather.location,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _C.accent)),
                const SizedBox(height: 2),
                Text(weather.condition,
                    style: const TextStyle(fontSize: 12, color: _C.muted)),
              ],
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.5), width: 1),
                  ),
                  child: Icon(_weatherIcon, color: _C.heading, size: 30),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _riskBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: _riskColor.withOpacity(0.5), width: 1),
                  ),
                  child: Text(
                    'Risk: $_riskLabel',
                    style: TextStyle(
                      color: _riskColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 14),

        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: _riskFactor,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(_riskColor),
            minHeight: 5,
          ),
        ),

        const SizedBox(height: 16),
        Divider(color: _C.heading.withOpacity(0.12), height: 1),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(child: _StatItem(icon: Icons.water,               label: 'Rainfall', value: '${weather.rainfall.toStringAsFixed(1)}mm')),
            Expanded(child: _StatItem(icon: Icons.water_drop_outlined,  label: 'Humidity', value: '${weather.humidity.toInt()}%')),
            Expanded(child: _StatItem(icon: Icons.air,                  label: 'Wind',     value: '${weather.windSpeed.toStringAsFixed(1)}m/s')),
            Expanded(child: _StatItem(icon: Icons.thermostat,           label: 'Feels',    value: '${weather.feelsLike.toStringAsFixed(0)}°C')),
          ],
        ),

        if (weather.isFloodRisk) ...[
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _C.riskHighBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _C.riskHigh.withOpacity(0.45), width: 1),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: _C.riskHigh, size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'High rainfall detected — flood risk in your area',
                    style: TextStyle(
                      fontSize: 12,
                      color: _C.riskHigh,
                      fontWeight: FontWeight.w700,
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

  const _StatItem({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: _C.purple, size: 18),
        const SizedBox(height: 5),
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 13, color: _C.heading)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10, color: _C.muted)),
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
  bool _expanded  = false;

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
    if (mounted) setState(() { _analysis = result; _isLoading = false; });
  }

  Color _safeColor(Color raw) {
    final hsl = HSLColor.fromColor(raw);
    return hsl.withLightness(hsl.lightness.clamp(0.0, 0.36)).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final weather = context.watch<WeatherViewModel>().weather;
    if (weather == null && !_isLoading) return const SizedBox.shrink();

    if (_isLoading) {
      return GlassContainer(
        padding: const EdgeInsets.all(16),
        child: const Row(
          children: [
            SizedBox(
              width: 18, height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: _C.heading),
            ),
            SizedBox(width: 12),
            Text('AI analysing flood risk...',
                style: TextStyle(fontSize: 13, color: _C.body)),
          ],
        ),
      );
    }

    if (_analysis == null) return const SizedBox.shrink();
    final a = _analysis!;
    final safe = _safeColor(a.riskColor);

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: GlassContainer(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.5), width: 1),
                  ),
                  child: const Icon(Icons.smart_toy_outlined,
                      color: _C.purple, size: 18),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('AI Flood Risk Analysis',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: _C.heading)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.72),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: safe.withOpacity(0.5), width: 1),
                  ),
                  child: Text(a.riskLevel,
                      style: TextStyle(
                          color: safe, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                Icon(
                  _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: _C.muted, size: 20,
                ),
              ],
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Text('Risk score: ${a.riskScore}/100',
                    style: const TextStyle(fontSize: 12, color: _C.body)),
                const SizedBox(width: 10),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: a.riskScore / 100,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(safe),
                      minHeight: 5,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Text(a.summary,
                style: const TextStyle(
                    fontSize: 13, height: 1.45, color: _C.body)),

            if (_expanded) ...[
              const SizedBox(height: 16),
              Divider(color: _C.heading.withOpacity(0.12), height: 1),
              const SizedBox(height: 14),

              const Text('📅 Forecast',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13, color: _C.heading)),
              const SizedBox(height: 6),
              Text(a.forecast,
                  style: const TextStyle(
                      fontSize: 13, color: _C.body, height: 1.45)),

              if (a.riskFactors.isNotEmpty) ...[
                const SizedBox(height: 14),
                const Text('⚠️ Risk Factors',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13, color: _C.heading)),
                const SizedBox(height: 8),
                ...a.riskFactors.map((f) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Icon(Icons.circle, size: 5, color: safe),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                              child: Text(f,
                                  style: const TextStyle(
                                      fontSize: 12, height: 1.4, color: _C.body))),
                        ],
                      ),
                    )),
              ],
              if (a.recommendations.isNotEmpty) ...[
                const SizedBox(height: 14),
                const Text('✅ Recommendations',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13, color: _C.heading)),
                const SizedBox(height: 8),
                ...a.recommendations.map((r) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 1),
                            child: Icon(Icons.check_circle_outline,
                                size: 15, color: _C.muted),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                              child: Text(r,
                                  style: const TextStyle(
                                      fontSize: 12, height: 1.4, color: _C.body))),
                        ],
                      ),
                    )),
              ],

              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _runAnalysis,
                  icon: const Icon(Icons.refresh, size: 14, color: _C.muted),
                  label: const Text('Refresh',
                      style: TextStyle(fontSize: 12, color: _C.muted)),
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
      description:
          'Rescue teams deployed across 12 affected areas in Kuala Lumpur',
      time: '15 mins ago',
      category: 'Emergency',
      categoryColor: _C.emergency,
    ),
    _NewsItem(
      title: 'Water Levels Rising in Klang Valley',
      description:
          'Authorities warn residents to stay vigilant as rainfall continues',
      time: '1 hour ago',
      category: 'Warning',
      categoryColor: _C.warning,
    ),
    _NewsItem(
      title: 'Relief Centers Opened',
      description: '8 temporary shelters now available for displaced residents',
      time: '2 hours ago',
      category: 'Relief',
      categoryColor: _C.relief,
    ),
    _NewsItem(
      title: 'Road Closures Updated',
      description: 'Major highways affected — check latest route information',
      time: '3 hours ago',
      category: 'Traffic',
      categoryColor: _C.traffic,
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
      _pageController.animateToPage(next,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut);
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
          height: 138,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: _newsItems.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(right: 10),
              child: _NewsCard(item: _newsItems[index]),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _newsItems.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == i ? 20 : 7,
              height: 7,
              decoration: BoxDecoration(
                color: _currentPage == i
                    ? _C.heading
                    : _C.muted.withOpacity(0.35),
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
  final String title, description, time, category;
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
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.72),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: item.categoryColor.withOpacity(0.5), width: 1),
                ),
                child: Text(
                  item.category.toUpperCase(),
                  style: TextStyle(
                      color: item.categoryColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const Spacer(),
              const Icon(Icons.access_time, size: 13, color: _C.muted),
              const SizedBox(width: 4),
              Text(item.time,
                  style: const TextStyle(fontSize: 11, color: _C.muted)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: _C.heading,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 5),
          Text(
            item.description,
            style: const TextStyle(
                fontSize: 12, color: _C.body, height: 1.35),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
