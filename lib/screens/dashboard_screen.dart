import 'package:flutter/material.dart';
import 'landmark_screen.dart';

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
    const LandmarkScreen(),
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
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(
                Icons.format_list_bulleted,
                color: _currentIndex == 0
                    ? const Color(0xFF800000)
                    : Colors.grey,
              ),
              onPressed: () => setState(() => _currentIndex = 0),
            ),
            IconButton(
              icon: Icon(
                Icons.school,
                color: _currentIndex == 1
                    ? const Color(0xFF800000)
                    : Colors.grey,
              ),
              onPressed: () => setState(() => _currentIndex = 1),
            ),

            const SizedBox(width: 48),
            IconButton(
              icon: Icon(
                Icons.emoji_events,
                color: _currentIndex == 3
                    ? const Color(0xFF800000)
                    : Colors.grey,
              ),
              onPressed: () => setState(() => _currentIndex = 3),
            ),

            IconButton(
              icon: Icon(
                Icons.person,
                color: _currentIndex == 4
                    ? const Color(0xFF800000)
                    : Colors.grey,
              ),
              onPressed: () => setState(() => _currentIndex = 4),
            ),
          ],
        ),
      ),
    );
  }
}
