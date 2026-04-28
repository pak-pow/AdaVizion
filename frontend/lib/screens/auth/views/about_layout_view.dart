import 'package:flutter/material.dart';
import 'package:adavizion/theme/app_colors.dart';

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
              color: AppColors.maroon,
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'EUventure, a mobile-first web application designed to modernize the EU111: University and I course at Manuel S. Enverga University Foundation by transforming traditional university orientation into an interactive and exploratory experience. This document outlines the purpose, core features, and functionalities of EUventure, including its user interfaces, system features, and the external and internal interfaces essential to its operation. It also specifies the technical and operational constraints under which the software must function.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.maroon,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'EUventure Logo',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppColors.maroon,
            ),
          ),
          const SizedBox(height: 16),
          Image.asset('assets/images/nav_logo.png', height: 80),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              "The EUventure logo is a modern and sleek design featuring a slipper-shaped pin form that symbolizes direction, movement, and exploration. At its center is the wildcat—the official mascot of Enverga University—serving as a bold representation of strength, pride, and school identity. The use of red as the primary color conveys passion, energy, and determination, reflecting the spirit of innovation and ambition within the EUventure community. The smooth, flowing curves of the logo enhance its contemporary feel, while the combination of shape and symbol creates a strong and memorable visual identity.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.maroon,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
