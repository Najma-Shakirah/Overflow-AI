import 'package:flutter/material.dart';
import 'game_view.dart'; 
import 'floodgame.dart';
import 'floodrisinggame/floodrisinggamepage.dart';

class GameDashboard extends StatelessWidget {
  const GameDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        // 1. Background Image Decoration
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background4.jpeg'), // Path to your image
            fit: BoxFit.cover,
          ),
        ),
        // 2. Dark Overlay (To make text pop)
        child: Container(
          color: Colors.black.withOpacity(0.4), 
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Flood Safety Games',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    padding: const EdgeInsets.all(20),
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    children: [
                      _GameCard(
                        title: 'Flood Snake',
                       imagePath: 'assets/images/snake.png',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SnakeGamePage()),
                        ),
                      ),
                      _GameCard(
                        title: 'Flood Survival',
                       
                       imagePath: 'assets/images/floodsurvival.png',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const FloodSurvivalGamePage()),
                        ),
                      ),
                      _GameCard(
                        title: 'Flood it Rising',
                      imagePath: 'assets/images/floodrising.png',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const FloodRisingGamePage()),
                        ),
                      ),
                      _GameCard(
                        title: 'Coming Soon',
                      imagePath: 'assets/images/sponge.jpg',
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Keep your _GameCard class exactly the same as before!
//gamecard
class _GameCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final VoidCallback onTap;

  const _GameCard({
    required this.title,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
           Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  // Fallback if image fails to load
                  errorBuilder: (context, error, stackTrace) => 
                      const Icon(Icons.broken_image, color: Colors.white),
                ),
              ),
            ),

            Expanded(
              flex: 1,
              child: Center(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}