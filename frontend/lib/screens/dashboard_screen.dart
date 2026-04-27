import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'quiz/quiz_list_screen.dart';
import 'dashboard/views/home_view.dart';
import 'dashboard/views/settings_view.dart';
import 'qrcode_screen.dart';
import 'landmarks/landmark_screen.dart';
import 'package:adavizion/theme/app_colors.dart';

// ============================================================================
// DASHBOARD SCREEN (Shell)
//
// Architecture: Center-docked FAB + BottomAppBar with notch + 4-tab IndexedStack.
//
// Tab routing:
//   0 → DashboardHomeView  (profile + badges + progress feed)
//   1 → LandmarkScreen (placeholder)
//   2 → QuizListScreen
//   3 → SettingsView (Profile & Settings)
//   FAB → QRCodeScreen (push navigation, NOT a tab)
//
// Extracted modules (unchanged):
//   dashboard/models/badge_model.dart    — BadgeCategory, BadgeConfig, kAchievementBadges
//   dashboard/views/home_view.dart       — DashboardHomeView (consolidated home + progress)
//   dashboard/views/settings_view.dart   — SettingsView
//   dashboard/widgets/badges_card.dart   — BadgesCard
// ============================================================================

class DashboardScreen extends StatefulWidget {
  final int initialTab;
  const DashboardScreen({super.key, this.initialTab = 0});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // ─── Tab state ─────────────────────────────────────────────────────────────
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTab;
  }

  // Nav item definitions — order must match the IndexedStack children order.
  // The SizedBox gap at index 2 in the BottomAppBar Row accounts for the FAB;
  // array indices 0‥3 map 1-to-1 to the four children below.
  static const _navItems = [
    (icon: Icons.home_rounded, label: 'Home'),
    (icon: Icons.place_rounded, label: 'Landmarks'),
    (icon: Icons.quiz_rounded, label: 'Quizzes'),
    (icon: Icons.person_outline, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,

      // ── APP BAR ──────────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Image.asset('assets/images/nav_logo.png', height: 40),
        flexibleSpace: Stack(
          clipBehavior: Clip.none, // Crucial for overflow
          children: [
            Positioned(
              top: -25, // Pulled back down
              right: 14, // Pulled back left
              child: Transform.rotate(
                angle: math.pi,
                child: Opacity(
                  opacity: 0.9,
                  child: Image.asset('assets/images/logo.png', height: 60),
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
          // Consolidated: profile + badges + milestone/progress/stat feed.
          const DashboardHomeView(),

          // ── Tab 1: Landmarks ──────────────────────────────────────────────
          // Placeholder until LandmarkScreen is implemented.
          const LandmarkScreen(),

          // ── Tab 2: Quizzes ───────────────────────────────────────────────
          QuizListScreen(
            onNavigateToTab: (index) => setState(() => _selectedIndex = index),
          ),

          // ── Tab 3: Profile & Settings ──────────────────────────────────
          // onEditProfile switches _selectedIndex to 0 so the user lands on
          // the Home tab where the profile edit pencil icon lives.
          SettingsView(onEditProfile: () => setState(() => _selectedIndex = 0)),
        ],
      ),

      // ── FAB: Center-docked QR Scanner ────────────────────────────────────────
      // shape: CircleBorder() ensures a perfect circle regardless of the theme's
      // default FAB shape (Material 3 uses a rounded-square by default).
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.maroon,
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
                color: isSelected ? AppColors.maroon : Colors.grey,
                size: 24,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.maroon : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
