import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const Center(
      child: Text("Landmarks List Screen", style: TextStyle(fontSize: 24)),
    ),
    const Center(child: Text("Quizzes Screen", style: TextStyle(fontSize: 24))),
    const SizedBox(),

    const Center(
      child: Text("Rankings Screen", style: TextStyle(fontSize: 24)),
    ),
    const Center(child: Text("Profile Screen", style: TextStyle(fontSize: 24))),
  ];

  @override
  Widget build(BuildContext content) {
    return Scaffold();
  }
}
