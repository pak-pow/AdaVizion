import 'package:flutter/material.dart';

class LandmarkScreen extends StatelessWidget {
  const LandmarkScreen({super.key});

  // TODO: Implement dynamic landmark fetching and replace placeholder UI.
  @override
  Widget build(BuildContext context) {
    const maroon = Color(0xFF7A1D1D);
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: maroon.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.place_rounded,
                size: 56,
                color: maroon,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Landmarks',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: maroon,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Coming soon',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
