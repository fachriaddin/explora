import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/signup_tour_guide.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://nhifbwpktgukcemsuunp.supabase.co', // ganti dengan URL kamu
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5oaWZid3BrdGd1a2NlbXN1dW5wIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQxMTI0ODYsImV4cCI6MjA1OTY4ODQ4Nn0.7xioX4ReM750DK0EmSkbLSgYokWvRwrwgyraJEkv6Y4', // ganti dengan anon key kamu
  );
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyDwZjf1EiXPrJFvkFc4YeI2zSzFMK6DCRc",
      authDomain: "explora-7db92.firebaseapp.com",
      projectId: "explora-7db92",
      storageBucket: "explora-7db92.firebasestorage.app",
      messagingSenderId: "219503498118",
      appId: "1:219503498118:web:cbafd33f53fe4a0b965207",
      measurementId: "G-W6BY8NNZB5"
    )
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Explora',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (_) => const SplashScreen(),
        '/onboarding': (_) => const OnboardingScreen(),
        '/login': (_) => const LoginScreen(),
        '/signup-tour-guide': (_) => const SignUpTourGuideScreen(),
        '/home': (_) => const HomeScreen(),
      },
    );
  }
}
