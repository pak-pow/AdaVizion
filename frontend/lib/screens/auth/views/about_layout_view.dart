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
            child: Column(
              children: [
                Text(
                  'EUventure is a mobile-first web application designed to modernize the orientation experience at Manuel S. Enverga University Foundation (MSEUF). By gamifying the EU111: University and I course, the platform shifts traditional classroom lectures into a hands-on, on-site exploration of the campus. Step out, scan the landmarks, and begin your adventure today!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.maroon,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Developed by AdaVizion. This is an independent student project and is not an official MSEUF platform.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.maroon,
                    height: 1.5,
                  ),
                ),
              ],
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
              'The EUventure logo features a modern design of dual footprints, symbolizing the physical journey and active exploration of the campus. At the center sits the wildcat, the official MSEUF mascot, representing strength, pride, and school identity. The use of maroon as the primary color reflects the spirit of the university, while the flowing curves of the design create a contemporary and memorable visual identity for the community.',
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
