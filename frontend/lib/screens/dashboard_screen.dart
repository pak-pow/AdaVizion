import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'quiz/quiz_list_screen.dart';
import '../services/api/api_config.dart';
import 'dashboard/views/home_view.dart';

// ============================================================================
// DASHBOARD SCREEN (Shell)
//
// This file now contains only the top-level Scaffold, AppBar, and the Stack
// that holds the decorative mascot watermark and the DashboardHomeView body.
//
// All extracted modules:
//   dashboard/models/badge_model.dart       — BadgeCategory, BadgeConfig, kAchievementBadges
//   dashboard/views/home_view.dart          — DashboardHomeView (profile card + QR prompt)
//   dashboard/views/progress_view.dart      — ProgressDashboardView (scoring dashboard)
//   dashboard/widgets/badges_card.dart      — BadgesCard (badge carousel)
// ============================================================================

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // --- BRAND COLORS ---
  static const _maroon = Color(0xFF7A1D1D);
  static const _maroonDark = Color(0xFF4A0F0F);
  static const _headerGrey = Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: _headerGrey,
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset('assets/images/nav_logo.png', height: 42),

            Row(
              children: [
                // LOG OUT
                GestureDetector(
                  onTap: _showLogoutConfirmation,
                  child: const Text(
                    'Log out',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _maroon,
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // QUIZZES
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const QuizListScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _maroonDark,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    minimumSize: const Size(0, 32),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 0,
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Quizzes',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      body: SizedBox.expand(
        child: Stack(
          children: [
            const DashboardHomeView(),

            Positioned(
              bottom: -224,
              left: 0,
              right: 0,
              child: RepaintBoundary(
                child: IgnorePointer(
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 500,
                    fit: BoxFit.contain,
                    alignment: Alignment.topCenter,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── LOGOUT ──────────────────────────────────────────────────────────────────
  void _showLogoutConfirmation() {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text(
            'Log out?',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: const Text('Are you sure you want to log out of EUventure?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Close dialog first
                await ApiConfig.logout(); // Clear JWT from shared_preferences
                if (mounted) {
                  // Replace the entire navigation stack — the back button
                  // cannot return to the dashboard after logout.
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const AuthScreen()),
                    (route) => false,
                  );
                }
              },
              child: const Text(
                'Log out',
                style: TextStyle(color: _maroon, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}
