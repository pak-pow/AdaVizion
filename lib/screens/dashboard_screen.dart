import 'package:flutter/material.dart';

// The `DashboardScreen` class is a stateful widget in Dart that represents a dashboard screen.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // The `int _currentIndex = 0;` line declares an integer variable named `_currentIndex` and
  // initializes it with a value of 0. This variable is typically used to keep track of the current
  // index or position within a list or array of items. In this case, it might be used to determine
  // which screen to display from the `_screens` list based on the current index value.
  int _currentIndex = 0;

  // The `final List<Widget> _screens` variable is an array that holds a list of Widgets.
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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "EUventure",
          style: TextStyle(
            color: Color(0xFF800000),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),

      body: _screens[_currentIndex],

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF800000),
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Camera Opening: Ready to scan landmark..."),
            ),
          );
        },
        child: const Icon(Icons.qr_code_scanner, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
