import 'dart:async';
import 'package:flutter/material.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<Offset>> _animations;

  final String splashText = "Explora";

  @override
  void initState() {
    super.initState();

    // Bounce animation per huruf
    _controllers = List.generate(splashText.length, (index) {
      return AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 800),
      );
    });

    _animations = _controllers.map((controller) {
      return Tween<Offset>(
        begin: Offset(0, -2),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.bounceOut));
    }).toList();

    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) _controllers[i].forward();
      });
    }

    // Timer untuk navigate ke onboarding
    Timer(Duration(seconds: 4), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: Duration(milliseconds: 800),
            pageBuilder: (_, __, ___) => OnboardingScreen(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFB73B67),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo
            Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Image.asset(
                'assets/logo.png',
                width: 80,
                height: 80,
              ),
            ),
            // Animasi teks per huruf
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(splashText.length, (index) {
                return SlideTransition(
                  position: _animations[index],
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2.0),
                    child: Text(
                      splashText[index],
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              }),
            ),
            // Slogan
            Padding(
              padding: EdgeInsets.only(top: 12.0),
              child: Text(
                "Your search ends here",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
