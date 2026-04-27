import 'package:flutter/material.dart';

// ============================================================================
// ABOUT LAYOUT VIEW
//
// Extracted from login_screen.dart _buildAboutLayout() (lines 364–415).
// Purely static display — no callbacks or state needed.
// ============================================================================

/// Static "About" page card shown when the user selects "About"
/// in the auth top navigation bar.
///
/// Extracted from `_AuthScreenState._buildAboutLayout()`.
class AboutLayoutView extends StatelessWidget {
  const AboutLayoutView({super.key});

  static const _maroon = Color(0xFF7A1D1D);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'About us',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: _maroon,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Lorem Ipsum is simply dummy text of the printing and typesetting industry...',
            textAlign: TextAlign.justify,
            style: TextStyle(fontSize: 12, color: _maroon, height: 1.5),
          ),
          const SizedBox(height: 32),
          const Text(
            'EUventure Logo',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: _maroon,
            ),
          ),
          const SizedBox(height: 16),
          Image.asset('assets/images/nav_logo.png', height: 80),
          const SizedBox(height: 16),
          const Text(
            'Lorem Ipsum is simply dummy text of the printing and typesetting industry...',
            textAlign: TextAlign.justify,
            style: TextStyle(fontSize: 12, color: _maroon, height: 1.5),
          ),
        ],
      ),
    );
  }
}
