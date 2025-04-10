import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to EXPLORA'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Logout and navigate to login screen
            // FirebaseAuth.instance.signOut();
            Navigator.popUntil(context, (route) => route.isFirst);
          },
          child: const Text('Logout'),
        ),
      ),
    );
  }
}
