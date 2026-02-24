import 'package:flutter/material.dart';
import '../navbar/navbar.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

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
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Welcome back!',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
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
                      ),
                      _ServiceButton(
                        icon: Icons.post_add,
                        label: 'Community Post',
                        color: Colors.green,
                        routeName: '/community',
                      ),
                       _ServiceButton(
                        icon: Icons.pending_actions,
                        label: 'Games',
                        color: Colors.red,
                        routeName: '/games',
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

class FloodInfoCard extends StatelessWidget {
  const FloodInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Weather
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
                        const Text(
                          '24°',
                          style: TextStyle(
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
                    const Text(
                      'Kuala Lumpur',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3A83B7).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.cloud_queue,
                    color: Color(0xFF3A83B7),
                    size: 32,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Status and Risk Meter
            Row(
              children: [
                const Text(
                  'Flood Risk: ',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                Text(
                  'MODERATE',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[700],
                  ),
                ),
                const Spacer(),
                Icon(Icons.speed, color: Colors.orange[700], size: 20),
              ],
            ),
            const SizedBox(height: 8),

            // Risk Meter Bar
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
                  widthFactor: 0.6,
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.green, Colors.yellow, Colors.orange],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Stats Grid
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    icon: Icons.water,
                    label: 'Water Level',
                    value: '2.4m',
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatItem(
                    icon: Icons.trending_up,
                    label: 'Rainfall',
                    value: '45mm',
                    color: Colors.indigo,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    icon: Icons.location_on,
                    label: 'Affected Areas',
                    value: '12',
                    color: Colors.red,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatItem(
                    icon: Icons.groups,
                    label: 'People Alerted',
                    value: '3,240',
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Info Text
            const Text(
              'Stay alert and monitor updates regularly.',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
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
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
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
    return Column(
      children: [
        InkWell(
          onTap: () {
            if (routeName != null) {
              Navigator.pushNamed(context, routeName!); // ← Uses named route
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
    // Auto-scroll every 4 seconds
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
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
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
        // Page indicator dots
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
