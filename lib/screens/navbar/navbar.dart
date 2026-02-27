import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const CustomBottomNavBar({super.key, required this.currentIndex, this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap:
          onTap ??
          (index) {
            // Default navigation behavior
            if (index == currentIndex) {
              return; // Don't navigate if already on this page
            }

            switch (index) {
              case 0:
                // Navigate to Home
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/', (route) => false);
                break;
              case 1:
                // Navigate to Alerts
                Navigator.of(context).pushNamed('/alerts');
                break;
              case 2:
                // Navigate to News
                Navigator.of(context).pushNamed('/news');
                break;
              case 3:
                // Navigate to Profile
                Navigator.of(context).pushNamed('/profile');
                break;
            }
          },
      selectedItemColor: const Color.fromARGB(255, 58, 131, 183),
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.warning), label: 'Alerts'),
        BottomNavigationBarItem(icon: Icon(Icons.feed_rounded), label: 'News'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}

class MonitorFAB extends StatelessWidget {
  final VoidCallback? onPressed;

  const MonitorFAB({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      width: 70,
      child: FloatingActionButton(
        onPressed:
            onPressed ??
            () {
              Navigator.of(context).pushNamed('/monitor');
            },
        backgroundColor: const Color.fromARGB(255, 58, 131, 183),
        shape: const CircleBorder(),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.waves, color: Colors.white, size: 20),
            SizedBox(height: 4),
            Text(
              'Monitor',
              style: TextStyle(color: Colors.white, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
