import 'package:flutter/material.dart';

// ============================================================================
// HOME LAYOUT VIEW
//
// Extracted from login_screen.dart _buildHomeLayout() (lines 328–359).
// Purely static display — no callbacks or state needed.
// ============================================================================

/// Static landing page content shown when the user selects "Homepage"
/// in the auth top navigation bar.
///
/// Extracted from `_AuthScreenState._buildHomeLayout()`.
class HomeLayoutView extends StatelessWidget {
  const HomeLayoutView({super.key});

  static const _maroon = Color(0xFF7A1D1D);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Column(
        children: const [
          Text(
            'Explore, Learn,\nand Enjoy',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: _maroon,
              height: 1.2,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'EUventure Interactive University\nExploration Platform',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: _maroon,
            ),
          ),
          SizedBox(
            height: 150,
          ), // Ensures scroll view has enough space over red background
        ],
      ),
    );
  }
}
