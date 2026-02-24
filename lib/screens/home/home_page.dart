import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../navbar/navbar.dart';
import '../weather/weather_viewmodel.dart';
import '../weather/weather_model.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    // Load weather when home page opens
    Future.microtask(() =>
        context.read<WeatherViewModel>().loadWeatherByLocation());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 46, 150, 199),
                    Color.fromARGB(255, 29, 255, 142),
                  ],
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
                    Text(
                      'Hello, user',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
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
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22.0),
              child: Column(
                children: [
                  const FloodInfoCard(),
                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _ServiceButton(
                        icon: Icons.pending_actions,
                        label: 'Checklist',
                        color: Colors.red,
                        routeName: '/checklist',
                      ),
                      const _ServiceButton(
                        icon: Icons.report,
                        label: 'Report',
                        color: Colors.orange,
                      ),
                      const _ServiceButton(
                        icon: Icons.house,
                        label: 'Shelters',
                        color: Colors.blue,
                        routeName: '/shelters',
                      ),
                      _ServiceButton(
                        icon: Icons.post_add,
                        label: 'Community Post',
                        color: Colors.green,
                        routeName: '/community',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Latest Updates',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  SizedBox(height: 12),
                  NewsCarousel(),
                ],
              ),
            ),
            const SizedBox(height: 200),
          ],
        ),
      ),
      floatingActionButton: const MonitorFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
    );
  }
}

// ================= FLOOD INFO CARD (now uses real weather) =================
class FloodInfoCard extends StatelessWidget {
  const FloodInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WeatherViewModel>();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: vm.isLoading
            ? const _LoadingWeather()
            : vm.weather != null
                ? _WeatherContent(weather: vm.weather!)
                : _ErrorWeather(
                    error: vm.error,
                    onRetry: () => context
                        .read<WeatherViewModel>()
                        .loadWeatherByLocation(),
                  ),
      ),
    );
  }
}

class _LoadingWeather extends StatelessWidget {
  const _LoadingWeather();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 120,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorWeather extends StatelessWidget {
  final String? error;
  final VoidCallback onRetry;

  const _ErrorWeather({this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off, color: Colors.grey[400], size: 32),
          const SizedBox(height: 8),
          Text(
            error ?? 'Could not load weather',
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _WeatherContent extends StatelessWidget {
  final WeatherModel weather;

  const _WeatherContent({required this.weather});

  String get _floodRiskLabel {
    if (weather.rainfall > 10) return 'HIGH';
    if (weather.rainfall > 5) return 'MODERATE';
    return 'LOW';
  }

  Color get _floodRiskColor {
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
    final condition = weather.condition.toLowerCase();
    if (condition.contains('rain') || condition.contains('drizzle')) {
      return Icons.grain;
    } else if (condition.contains('thunder')) {
      return Icons.thunderstorm;
    } else if (condition.contains('cloud')) {
      return Icons.cloud_queue;
    } else if (condition.contains('clear')) {
      return Icons.wb_sunny;
    }
    return Icons.cloud_queue;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
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
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3A83B7),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Icon(
                        Icons.water_drop,
                        color: Colors.blue[300],
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  weather.location,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  weather.condition,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF3A83B7).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _weatherIcon,
                color: const Color(0xFF3A83B7),
                size: 32,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Flood risk label
        Row(
          children: [
            const Text(
              'Flood Risk: ',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            Text(
              _floodRiskLabel,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: _floodRiskColor,
              ),
            ),
            const Spacer(),
            Icon(Icons.speed, color: _floodRiskColor, size: 20),
          ],
        ),
        const SizedBox(height: 8),

        // Risk bar
        Stack(
          children: [
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey[200],
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
        const SizedBox(height: 8),

        // Stats row
        Row(
          children: [
            Expanded(
              child: _StatItem(
                icon: Icons.water,
                label: 'Rainfall',
                value: '${weather.rainfall.toStringAsFixed(1)}mm',
                color: Colors.blue,
              ),
            ),
            Expanded(
              child: _StatItem(
                icon: Icons.water_drop_outlined,
                label: 'Humidity',
                value: '${weather.humidity.toInt()}%',
                color: Colors.teal,
              ),
            ),
            Expanded(
              child: _StatItem(
                icon: Icons.thermostat,
                label: 'Temp',
                value: '${weather.temperature.toStringAsFixed(1)}°C',
                color: Colors.orange,
              ),
            ),
          ],
        ),

        // Flood risk warning banner
        if (weather.isFloodRisk) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: Colors.red[700], size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '⚠️ High rainfall detected — flood risk in your area',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red[700],
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
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey[500]),
        ),
      ],
    );
  }
}

// ================= SERVICE BUTTON =================
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
    return Column(
      children: [
        InkWell(
          onTap: () {
            if (routeName != null) {
              Navigator.pushNamed(context, routeName!);
            }
          },
          borderRadius: BorderRadius.circular(40),
          child: Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(fontSize: 12, color: color)),
      ],
    );
  }
}

// ================= NEWS CAROUSEL =================
class NewsCarousel extends StatefulWidget {
  const NewsCarousel({super.key});

  @override
  State<NewsCarousel> createState() => _NewsCarouselState();
}

class _NewsCarouselState extends State<NewsCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<NewsItem> _newsItems = [
    NewsItem(
      title: 'Emergency Services on High Alert',
      description:
          'Rescue teams deployed across 12 affected areas in Kuala Lumpur',
      time: '15 mins ago',
      category: 'Emergency',
      categoryColor: Colors.red,
    ),
    NewsItem(
      title: 'Water Levels Rising in Klang Valley',
      description:
          'Authorities warn residents to stay vigilant as rainfall continues',
      time: '1 hour ago',
      category: 'Warning',
      categoryColor: Colors.orange,
    ),
    NewsItem(
      title: 'Relief Centers Opened',
      description: '8 temporary shelters now available for displaced residents',
      time: '2 hours ago',
      category: 'Relief',
      categoryColor: Colors.blue,
    ),
    NewsItem(
      title: 'Road Closures Updated',
      description: 'Major highways affected - check latest route information',
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
      int nextPage = (_currentPage + 1) % _newsItems.length;
      _pageController.animateToPage(
        nextPage,
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
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: _newsItems.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: NewsCard(newsItem: _newsItems[index]),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _newsItems.length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? const Color(0xFF3A83B7)
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class NewsItem {
  final String title;
  final String description;
  final String time;
  final String category;
  final Color categoryColor;

  NewsItem({
    required this.title,
    required this.description,
    required this.time,
    required this.category,
    required this.categoryColor,
  });
}

class NewsCard extends StatelessWidget {
  final NewsItem newsItem;

  const NewsCard({super.key, required this.newsItem});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            newsItem.categoryColor.withOpacity(0.1),
            newsItem.categoryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: newsItem.categoryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: newsItem.categoryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    newsItem.category.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  newsItem.time,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              newsItem.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              newsItem.description,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}