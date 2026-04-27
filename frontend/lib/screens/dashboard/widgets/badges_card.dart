import 'package:flutter/material.dart';
import '../models/badge_model.dart';
import '../../../services/api/achievement_api.dart';

// ============================================================================
// BADGES CARD WIDGET
// ============================================================================

/// Self-contained achievements badge carousel card shown on the dashboard.
///
/// Manages its own filter-tab state and scroll controller.
class BadgesCard extends StatefulWidget {
  final int quizPoints;
  final int landmarksVisited;

  const BadgesCard({
    super.key,
    required this.quizPoints,
    required this.landmarksVisited,
  });

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

  /// Dynamic data future from backend.
  late Future<List<BadgeConfig>> _achievementsFuture;

  @override
  void initState() {
    super.initState();
    _achievementsFuture = AchievementApi.getAchievements();
  }

  @override
  void dispose() {
    _badgeScrollController.dispose();
    super.dispose();
  }

  List<BadgeConfig> _filterAndOverrideBadges(List<BadgeConfig> allBadges) {
    // 1. Filter by category selector
    final categoryBadges = _selectedBadgeFilter == null
        ? allBadges
        : allBadges.where((b) => b.category == _selectedBadgeFilter).toList();

    // 2. Override locked state based on live dashboard stats (Immediate UI Feedback)
    return categoryBadges.map((badge) {
      bool isLocked = badge.isLocked;
      if (badge.category == BadgeCategory.scholar) {
        if (widget.quizPoints >= badge.threshold) isLocked = false;
      } else if (badge.category == BadgeCategory.explorer) {
        if (widget.landmarksVisited >= badge.threshold) isLocked = false;
      }

      return BadgeConfig(
        label: badge.label,
        sublabel: badge.sublabel,
        category: badge.category,
        isLocked: isLocked,
        imgPath: badge.imgPath,
        threshold: badge.threshold,
        tier: badge.tier,
        description: badge.description,
        funFact: badge.funFact,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _maroon,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Row 1: Title ───────────────────────────────────────────────────
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
              const Spacer(),
              FutureBuilder<List<BadgeConfig>>(
                future: _achievementsFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox();
                  final all = snapshot.data!;
                  final earned = all.where((b) {
                    bool locked = b.isLocked;
                    if (b.category == BadgeCategory.scholar) {
                      if (widget.quizPoints >= b.threshold) locked = false;
                    } else {
                      if (widget.landmarksVisited >= b.threshold)
                        locked = false;
                    }
                    return !locked;
                  }).length;

                  return Text(
                    '$earned/${all.length}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
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
            height: 120, // coin 72 + 5 gap + ~32 label + 51 safety
            child: FutureBuilder<List<BadgeConfig>>(
              future: _achievementsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      'Failed to load achievements',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  );
                }

                final allBadges = snapshot.data ?? [];
                final visibleBadges = _filterAndOverrideBadges(allBadges);

                if (visibleBadges.isEmpty) {
                  return const Center(
                    child: Text(
                      'No badges available in this category.',
                      style: TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                  );
                }

                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: ListView.separated(
                    key: ValueKey(_selectedBadgeFilter),
                    controller: _badgeScrollController,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(right: 8),
                    physics: const BouncingScrollPhysics(),
                    itemCount: visibleBadges.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 14),
                    itemBuilder: (_, i) =>
                        _buildBadgePlaceholder(config: visibleBadges[i]),
                  ),
                );
              },
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

  /// Renders a single badge item for the Carousel.
  Widget _buildBadgePlaceholder({required BadgeConfig config}) {
    const double size = 72;

    // Category accent colour for the small sublabel.
    final chipColor = config.category == BadgeCategory.explorer
        ? const Color(0xFFE8A87C)
        : const Color(0xFFFFD700);

    Widget imageWidget;
    if (config.imgPath == null || config.imgPath!.isEmpty) {
      imageWidget = Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          config.category == BadgeCategory.explorer
              ? Icons.explore_outlined
              : Icons.school_outlined,
          color: Colors.white.withValues(alpha: 0.7),
          size: 28,
        ),
      );
    } else {
      imageWidget = Padding(
        padding: const EdgeInsets.all(6.0),
        child: Image.network(
          config.imgPath!,
          width: 52,
          height: 52,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white70,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.broken_image_outlined,
            color: Colors.white.withValues(alpha: 0.70),
            size: 28,
          ),
        ),
      );
    }

    if (config.isLocked) {
      // Locked state: Greyscale, opacity, overlay lock + Circular Clip Fix
      imageWidget = Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.black.withValues(
            alpha: 0.15,
          ), // Flat dark grey / transparent circle
          shape: BoxShape.circle,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Opacity(
              opacity: 0.4,
              child: ColorFiltered(
                colorFilter: const ColorFilter.matrix([
                  0.2126,
                  0.7152,
                  0.0722,
                  0,
                  0,
                  0.2126,
                  0.7152,
                  0.0722,
                  0,
                  0,
                  0.2126,
                  0.7152,
                  0.0722,
                  0,
                  0,
                  0,
                  0,
                  0,
                  1,
                  0,
                ]),
                child: imageWidget,
              ),
            ),
            const Icon(Icons.lock, color: Colors.white, size: 24),
          ],
        ),
      );
    } else {
      // Unlocked state: "Medal Holder" Pedestal Design (3D Feel)
      imageWidget = Container(
        padding: const EdgeInsets.all(1.0), // Tight thin outer maroon border
        decoration: const BoxDecoration(color: _maroon, shape: BoxShape.circle),
        child: Container(
          padding: const EdgeInsets.all(
            2.5,
          ), // Inner silver/metallic grey border
          decoration: const BoxDecoration(
            color: Color(0xFFC0C0C0), // Silver / Metallic Grey
            shape: BoxShape.circle,
          ),
          child: Container(
            padding: const EdgeInsets.all(
              2.0,
            ), // Reduced from 6.0 to account for image padding
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: imageWidget,
          ),
        ),
      );
    }

    return InkWell(
      onTap: () => _showBadgeDetails(config),
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 86, // Increased width to give text more horizontal room
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: size,
              width: size,
              child: Center(child: imageWidget),
            ),
            const SizedBox(height: 6),
            Text(
              config.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: config.isLocked
                    ? Colors.white.withValues(alpha: 0.50)
                    : Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Modal Details View ────────────────────────────────────────────────────

  void _showBadgeDetails(BadgeConfig config) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        Widget largeImageWidget;
        if (config.imgPath == null || config.imgPath!.isEmpty) {
          largeImageWidget = Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              config.category == BadgeCategory.explorer
                  ? Icons.explore_outlined
                  : Icons.school_outlined,
              color: Colors.grey.shade300,
              size: 60,
            ),
          );
        } else {
          largeImageWidget = Image.network(
            config.imgPath!,
            width: 120,
            height: 120,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Icon(
              Icons.broken_image_outlined,
              color: Colors.grey.shade400,
              size: 60,
            ),
          );
        }

        if (config.isLocked) {
          largeImageWidget = Stack(
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: 0.4,
                child: ColorFiltered(
                  colorFilter: const ColorFilter.matrix([
                    0.2126,
                    0.7152,
                    0.0722,
                    0,
                    0,
                    0.2126,
                    0.7152,
                    0.0722,
                    0,
                    0,
                    0.2126,
                    0.7152,
                    0.0722,
                    0,
                    0,
                    0,
                    0,
                    0,
                    1,
                    0,
                  ]),
                  child: largeImageWidget,
                ),
              ),
              const Icon(Icons.lock, color: Colors.grey, size: 48),
            ],
          );
        }

        return Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Hero(tag: 'badge-${config.label}', child: largeImageWidget),
                  const SizedBox(height: 24),
                  Text(
                    config.label,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: _maroon,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (config.description != null &&
                      config.description!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      config.isLocked
                          ? "Keep exploring to unlock this lore!"
                          : config.description!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      'Required: ${config.threshold} ${config.category == BadgeCategory.scholar ? 'points' : 'landmarks'}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                  if (!config.isLocked &&
                      config.funFact != null &&
                      config.funFact!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F7F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: const Color(
                              0xFFFFD700,
                            ).withValues(alpha: 0.8),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              config.funFact!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
