import 'package:flutter/material.dart';
import '../models/badge_model.dart';
import '../views/progress_view.dart';

// ============================================================================
// BADGES CARD WIDGET
//
// Extracted from dashboard_screen.dart _buildBadgesCard(), _buildFilterTab(),
// and _buildBadgePlaceholder() methods in _DashboardHomeViewState.
//
// The badge filter state (_selectedBadgeFilter, _badgeScrollController)
// is promoted to this widget's own state since nothing outside the card
// reads or writes those values.
// ============================================================================

/// Self-contained achievements badge carousel card shown on the dashboard.
///
/// Manages its own filter-tab state and scroll controller.
/// Navigates to [ProgressDashboardView] when the "Quiz Scores" button is tapped.
class BadgesCard extends StatefulWidget {
  const BadgesCard({super.key});

  @override
  State<BadgesCard> createState() => _BadgesCardState();
}

class _BadgesCardState extends State<BadgesCard> {
  // ─── Brand colour ─────────────────────────────────────────────────────────
  static const _maroon = Color(0xFF7A1D1D);

  // ─── Local state ──────────────────────────────────────────────────────────
  /// null = All categories. Otherwise filters the carousel to one category.
  BadgeCategory? _selectedBadgeFilter;

  /// Controller for the horizontal badge carousel.
  final _badgeScrollController = ScrollController();

  @override
  void dispose() {
    _badgeScrollController.dispose();
    super.dispose();
  }

  List<BadgeConfig> get _visibleBadges => _selectedBadgeFilter == null
      ? kAchievementBadges
      : kAchievementBadges
            .where((b) => b.category == _selectedBadgeFilter)
            .toList();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: BoxDecoration(
        color: _maroon,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Row 1: Title + Quiz Scores button ──────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Badges',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProgressDashboardView(),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: const Size(0, 30),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                ),
                child: const Text(
                  'Quiz Scores',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Row 2: Filter tabs (All · Explorer · Scholar) ──────────────────
          Row(
            children: [
              _buildFilterTab(
                label: 'All',
                icon: Icons.apps_rounded,
                isActive: _selectedBadgeFilter == null,
                activeColor: Colors.white,
                onTap: () => setState(() {
                  _selectedBadgeFilter = null;
                  _badgeScrollController.jumpTo(0);
                }),
              ),
              const SizedBox(width: 8),
              _buildFilterTab(
                label: 'Explorer',
                icon: Icons.explore_outlined,
                isActive: _selectedBadgeFilter == BadgeCategory.explorer,
                activeColor: const Color(0xFFE8A87C),
                onTap: () => setState(() {
                  _selectedBadgeFilter = BadgeCategory.explorer;
                  _badgeScrollController.jumpTo(0);
                }),
              ),
              const SizedBox(width: 8),
              _buildFilterTab(
                label: 'Scholar',
                icon: Icons.school_outlined,
                isActive: _selectedBadgeFilter == BadgeCategory.scholar,
                activeColor: const Color(0xFFFFD700),
                onTap: () => setState(() {
                  _selectedBadgeFilter = BadgeCategory.scholar;
                  _badgeScrollController.jumpTo(0);
                }),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Row 3: Horizontal badge carousel ──────────────────────────────
          // Hint of overflow on the right edge signals that the list is scrollable.
          SizedBox(
            height: 108, // coin 72 + 5 gap + ~18 label + 13 safety
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: ListView.separated(
                key: ValueKey(_selectedBadgeFilter),
                controller: _badgeScrollController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(right: 8),
                physics: const BouncingScrollPhysics(),
                itemCount: _visibleBadges.length,
                separatorBuilder: (_, _) => const SizedBox(width: 14),
                itemBuilder: (_, i) =>
                    _buildBadgePlaceholder(config: _visibleBadges[i]),
              ),
            ),
          ),

          // ── Row 4: Scroll hint ─────────────────────────────────────────────
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chevron_left_rounded,
                color: Colors.white.withValues(alpha: 0.4),
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                'swipe to browse',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 9,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.white.withValues(alpha: 0.4),
                size: 16,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Filter tab helper ─────────────────────────────────────────────────────

  /// A pill-shaped filter tab button for the badge category selector.
  Widget _buildFilterTab({
    required String label,
    required IconData icon,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? activeColor.withValues(alpha: 0.22)
              : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isActive
                ? activeColor.withValues(alpha: 0.70)
                : Colors.white.withValues(alpha: 0.18),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive
                  ? activeColor
                  : Colors.white.withValues(alpha: 0.55),
              size: 13,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: isActive
                    ? activeColor
                    : Colors.white.withValues(alpha: 0.55),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Badge coin helper ─────────────────────────────────────────────────────

  /// Renders a single coin-shaped achievement badge for the carousel.
  ///
  /// Locked  → grey gradient + semi-transparent lock icon
  /// Unlocked → category-tinted gradient + category icon
  Widget _buildBadgePlaceholder({required BadgeConfig config}) {
    const double size = 72;

    final List<Color> gradient;
    final Color iconColor;
    final IconData icon;

    if (config.isLocked) {
      gradient = [Colors.grey.shade300, Colors.grey.shade400];
      iconColor = Colors.white.withValues(alpha: 0.70);
      icon = Icons.lock_outline_rounded;
    } else if (config.category == BadgeCategory.explorer) {
      gradient = [const Color(0xFFE8A87C), const Color(0xFFC0703A)];
      iconColor = Colors.white;
      icon = Icons.explore_outlined;
    } else {
      gradient = [const Color(0xFFFFE066), const Color(0xFFFFB300)];
      iconColor = Colors.white;
      icon = Icons.school_outlined;
    }

    // Category accent colour for the small sublabel.
    final chipColor = config.category == BadgeCategory.explorer
        ? const Color(0xFFE8A87C)
        : const Color(0xFFFFD700);

    return SizedBox(
      width: size,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Coin ──
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradient,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      (config.isLocked ? Colors.grey.shade400 : gradient.last)
                          .withValues(alpha: 0.50),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(height: 6),

          // ── Badge name ──
          Text(
            config.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: config.isLocked
                  ? Colors.white.withValues(alpha: 0.50)
                  : Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),

          // ── Sublabel (threshold hint) ──
          Text(
            config.sublabel,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: config.isLocked
                  ? Colors.white.withValues(alpha: 0.28)
                  : chipColor.withValues(alpha: 0.85),
              fontSize: 7.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
