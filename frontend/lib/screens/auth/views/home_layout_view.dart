import 'package:adavizion/theme/app_colors.dart';
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
              color: AppColors.maroon,
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
              color: AppColors.maroon,
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
