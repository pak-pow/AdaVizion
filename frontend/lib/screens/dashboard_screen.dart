import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'quiz/quiz_list_screen.dart';
import '../services/api/api_config.dart';
import 'dashboard/views/home_view.dart';
import 'dashboard/views/progress_view.dart';
import 'qrcode_screen.dart';

// ============================================================================
// DASHBOARD SCREEN (Shell)
//
// Architecture: Center-docked FAB + BottomAppBar with notch + 4-tab IndexedStack.
//
// Tab routing:
//   0 → DashboardHomeView  (profile card + badges)
//   1 → _LandmarksPlaceholder (stub — pending LandmarkScreen implementation)
//   2 → QuizListScreen
//   3 → ProgressDashboardView
//   FAB → QRCodeScreen (push navigation, NOT a tab)
//
// Extracted modules (unchanged):
//   dashboard/models/badge_model.dart    — BadgeCategory, BadgeConfig, kAchievementBadges
//   dashboard/views/home_view.dart       — DashboardHomeView
//   dashboard/views/progress_view.dart   — ProgressDashboardView
//   dashboard/widgets/badges_card.dart   — BadgesCard
// ============================================================================

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // ─── Brand colours ─────────────────────────────────────────────────────────
  static const _maroon = Color(0xFF7A1D1D);
  static const _headerGrey = Color(0xFFF5F5F5);

  // ─── Tab state ─────────────────────────────────────────────────────────────
  int _selectedIndex = 0;

  // Nav item definitions — order must match the IndexedStack children order.
  // The SizedBox gap at index 2 in the BottomAppBar Row accounts for the FAB;
  // array indices 0‥3 map 1-to-1 to the four children below.
  static const _navItems = [
    (icon: Icons.home_rounded, label: 'Home'),
    (icon: Icons.place_rounded, label: 'Landmarks'),
    (icon: Icons.quiz_rounded, label: 'Quizzes'),
    (icon: Icons.military_tech_rounded, label: 'Progress'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ── APP BAR ──────────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: _headerGrey,
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset('assets/images/nav_logo.png', height: 42),
            // The "Quizzes" shortcut button has been removed — it is now the
            // dedicated Quizzes tab in the BottomAppBar.
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
          ],
        ),
      ),

      // ── BODY: IndexedStack keeps every tab widget alive, preserving their
      //   internal scroll positions and async state across tab switches. ───────
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          // ── Tab 0: Home ─────────────────────────────────────────────────────
          // Wrapped in a Stack to layer the decorative mascot watermark under
          // the scroll content without interfering with touch events.
          Stack(
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

          // ── Tab 1: Landmarks ─────────────────────────────────────────────────
          // Placeholder until LandmarkScreen is implemented.
          const _LandmarksPlaceholder(),

          // ── Tab 2: Quizzes ───────────────────────────────────────────────────
          // QuizListScreen manages its own Scaffold + AppBar within the tab body.
          const QuizListScreen(),

          // ── Tab 3: Progress ──────────────────────────────────────────────────
          // ProgressDashboardView manages its own Scaffold + AppBar within the tab body.
          const ProgressDashboardView(),
        ],
      ),

      // ── FAB: Center-docked QR Scanner ────────────────────────────────────────
      // shape: CircleBorder() ensures a perfect circle regardless of the theme's
      // default FAB shape (Material 3 uses a rounded-square by default).
      floatingActionButton: FloatingActionButton(
        backgroundColor: _maroon,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        tooltip: 'Scan QR Code',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const QRCodeScreen()),
          );
        },
        child: const Icon(Icons.qr_code_scanner, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // ── BOTTOM APP BAR ───────────────────────────────────────────────────────
      // CircularNotchedRectangle punches a cutout for the FAB.
      // notchMargin gives breathing room between the FAB edge and the bar.
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.white,
        elevation: 8,
        child: SizedBox(
          height: 60.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0),
              _buildNavItem(1),
              // Empty gutter — sits directly under the docked FAB so items
              // on either side are not obscured by the button.
              const SizedBox(width: 48),
              _buildNavItem(2),
              _buildNavItem(3),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Nav item builder ───────────────────────────────────────────────────────
  Widget _buildNavItem(int index) {
    final item = _navItems[index];
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                item.icon,
                key: ValueKey(isSelected),
                color: isSelected ? _maroon : Colors.grey,
                size: 24,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? _maroon : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Logout dialog ──────────────────────────────────────────────────────────
  void _showLogoutConfirmation() {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text(
            'Log out?',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: const Text(
            'Are you sure you want to log out of EUventure?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await ApiConfig.logout();
                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const AuthScreen()),
                    (route) => false,
                  );
                }
              },
              child: const Text(
                'Log out',
                style: TextStyle(
                  color: _maroon,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ============================================================================
// LANDMARKS PLACEHOLDER
//
// Temporary stub rendered in the Landmarks tab until the real LandmarkScreen
// widget is implemented. Replace by importing and referencing the real screen.
// ============================================================================

class _LandmarksPlaceholder extends StatelessWidget {
  const _LandmarksPlaceholder();

  static const _maroon = Color(0xFF7A1D1D);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _maroon.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.place_rounded,
              size: 56,
              color: _maroon,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Landmarks',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: _maroon,
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
    );
  }
}
