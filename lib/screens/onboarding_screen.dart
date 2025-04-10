import 'package:flutter/material.dart';
import 'dart:math';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _floatAnimation;

  final List<Map<String, dynamic>> _pages = [
    {
      "title": "Popular places in Surakarta",
      "description":
          "Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
      "images": [
        "assets/images/keraton solo.png",
        "assets/images/mahkota.png",
        "assets/images/lokananta.png",
        "assets/images/mangkunegaran.png",
        "assets/images/zayed.png",
      ]
    },
    {
      "title": "Discover Local Foods",
      "description": "Taste the traditional dishes of Solo with a modern twist.",
      "images": [
        "assets/images/mbaklies.png",
        "assets/images/notosuman.jpg",
        "assets/images/ademayem.jpg",
      ]
    },
    {
      "title": "Cultural Heritage",
      "description":
          "Explore temples, museums, and local art galleries in Solo.",
      "images": [
        "assets/images/mbaklies.png",
        "assets/images/notosuman.jpg",
        "assets/images/ademayem.jpg",
      ]
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -5, end: 5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentIndex < _pages.length - 1) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => LoginScreen()));
    }
  }

  Widget _buildBubbleImages(List<String> imagePaths) {
    final random = Random();
    final List<Map<String, dynamic>> positions = [];

    bool isOverlapping(double top, double left, double size) {
      for (var pos in positions) {
        final dx = (pos['left'] - left).abs();
        final dy = (pos['top'] - top).abs();
        final distance = sqrt(dx * dx + dy * dy);
        final minDistance = (pos['size'] + size) / 2 + 14;
        if (distance < minDistance) return true;
      }
      return false;
    }

    for (int i = 0; i < imagePaths.length; i++) {
      double size = 130.0 + random.nextInt(40); // ukuran bubble diperbesar
      double top = 20.0 + random.nextDouble() * 400;
      double left = 20.0 + random.nextDouble() * 200;
      int tries = 0;

      while (isOverlapping(top, left, size) && tries < 100) {
        top = 20.0 + random.nextDouble() * 400;
        left = 20.0 + random.nextDouble() * 200;
        tries++;
      }

      positions.add({
        'size': size,
        'top': top,
        'left': left,
        'drift': random.nextBool() ? 1 : -1,
      });
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Stack(
          children: List.generate(imagePaths.length, (i) {
            final bubble = positions[i];
            return Positioned(
              top: (bubble['top'] as double) +
                  (_floatAnimation.value * (bubble['drift'] as int)),
              left: bubble['left'] as double,
              child: CircleAvatar(
                radius: (bubble['size'] as double) / 2,
                backgroundImage: AssetImage(imagePaths[i]),
              ),
            );
          }),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemCount: _pages.length,
              itemBuilder: (_, index) {
                final page = _pages[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: TextButton(
                          onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => LoginScreen()),
                          ),
                          child: const Text("Skip",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: _buildBubbleImages(page["images"]),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        page["title"],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        page["description"],
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: List.generate(_pages.length, (i) {
                              return Container(
                                margin: const EdgeInsets.only(right: 5),
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _currentIndex == i
                                      ? Colors.pinkAccent
                                      : Colors.white24,
                                ),
                              );
                            }),
                          ),
                          GestureDetector(
                            onTap: _nextPage,
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: const BoxDecoration(
                                color: Colors.pinkAccent,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.arrow_forward,
                                  color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
