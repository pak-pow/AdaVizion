// Extracted from dashboard_screen.dart (lines 1745–1768 + static badge list lines 458–495).
// Made public (underscore removed) so all dashboard sub-views can share these types.

/// Maps to the backend `AchievementCategory` Prisma enum.
enum BadgeCategory { explorer, scholar }

/// Lightweight config for a single badge coin in the carousel UI.
///
/// [sublabel] surfaces the threshold condition from the seed data.
/// When real API data is wired, replace [isLocked] with a live earned check.
class BadgeConfig {
  final String label;
  final String sublabel;
  final BadgeCategory category;
  final bool isLocked;

  const BadgeConfig({
    required this.label,
    required this.sublabel,
    required this.category,
    required this.isLocked,
  });
}

// The backend `Achievement` model has 6 seeded entries across two categories:
//   EXPLORER (landmark-based): Envergan Scout, Wildcat Voyager, Luzonian Trailblazer
//   SCHOLAR  (quiz-point-based): Envergan Aspirant, Wildcat Seeker, Luzonian Paragon
// Each achievement has: achievement_id, title, description, category, threshold, img_path.
// Badges are locked until the student reaches the achievement's threshold.

/// The six seeded achievement badges, mirroring the backend achievements seed data.
const List<BadgeConfig> kAchievementBadges = [
  BadgeConfig(
    label: 'Scout',
    sublabel: 'Visit 1 landmark',
    category: BadgeCategory.explorer,
    isLocked: true,
  ),
  BadgeConfig(
    label: 'Voyager',
    sublabel: 'Visit 5 landmarks',
    category: BadgeCategory.explorer,
    isLocked: true,
  ),
  BadgeConfig(
    label: 'Trailblazer',
    sublabel: 'Visit all landmarks',
    category: BadgeCategory.explorer,
    isLocked: true,
  ),
  BadgeConfig(
    label: 'Aspirant',
    sublabel: '50 quiz pts',
    category: BadgeCategory.scholar,
    isLocked: true,
  ),
  BadgeConfig(
    label: 'Seeker',
    sublabel: '100 quiz pts',
    category: BadgeCategory.scholar,
    isLocked: true,
  ),
  BadgeConfig(
    label: 'Paragon',
    sublabel: '150 quiz pts',
    category: BadgeCategory.scholar,
    isLocked: true,
  ),
];
