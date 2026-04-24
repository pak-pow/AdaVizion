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
  final String? imgPath;
  final int threshold;

  const BadgeConfig({
    required this.label,
    required this.sublabel,
    required this.category,
    this.isLocked = true,
    this.imgPath,
    required this.threshold,
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
    threshold: 1,
    imgPath: 'https://eufjupzszpgeadrnvigc.supabase.co/storage/v1/object/public/achievement-badges/explorer-level-1.svg',
  ),
  BadgeConfig(
    label: 'Voyager',
    sublabel: 'Visit 5 landmarks',
    category: BadgeCategory.explorer,
    threshold: 5,
    imgPath: 'https://eufjupzszpgeadrnvigc.supabase.co/storage/v1/object/public/achievement-badges/explorer-level-2.svg',
  ),
  BadgeConfig(
    label: 'Trailblazer',
    sublabel: 'Visit all landmarks',
    category: BadgeCategory.explorer,
    threshold: 10,
    imgPath: 'https://eufjupzszpgeadrnvigc.supabase.co/storage/v1/object/public/achievement-badges/explorer-level-3.svg',
  ),
  BadgeConfig(
    label: 'Aspirant',
    sublabel: '50 quiz pts',
    category: BadgeCategory.scholar,
    threshold: 50,
    imgPath: 'https://eufjupzszpgeadrnvigc.supabase.co/storage/v1/object/public/achievement-badges/scholar-level-1.svg',
  ),
  BadgeConfig(
    label: 'Seeker',
    sublabel: '100 quiz pts',
    category: BadgeCategory.scholar,
    threshold: 100,
    imgPath: 'https://eufjupzszpgeadrnvigc.supabase.co/storage/v1/object/public/achievement-badges/scholar-level-2.svg',
  ),
  BadgeConfig(
    label: 'Paragon',
    sublabel: '150 quiz pts',
    category: BadgeCategory.scholar,
    threshold: 150,
    imgPath: 'https://eufjupzszpgeadrnvigc.supabase.co/storage/v1/object/public/achievement-badges/scholar-level-3.svg',
  ),
];
