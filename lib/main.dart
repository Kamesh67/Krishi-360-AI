import 'package:flutter/material.dart';
import 'dashboard_screen.dart';

void main() {
  runApp(const Krishi360AI());
}

class Krishi360AI extends StatelessWidget {
  const Krishi360AI({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Krishi360 AI',
      home: DashboardScreen(),
    );
  }
}