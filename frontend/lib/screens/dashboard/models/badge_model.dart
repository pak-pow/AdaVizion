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
  final int? tier;
  final String? description;
  final String? funFact;

  const BadgeConfig({
    required this.label,
    required this.sublabel,
    required this.category,
    this.isLocked = true,
    this.imgPath,
    required this.threshold,
    this.tier,
    this.description,
    this.funFact,
  });

  /// Factory to safely parse achievement data from the backend API.
  /// Backend keys: title, description, category, threshold, img_path, is_unlocked, etc.
  factory BadgeConfig.fromJson(Map<String, dynamic> json) {
    final catStr = json['category'] as String? ?? 'EXPLORER';
    final category = catStr.toUpperCase() == 'SCHOLAR'
        ? BadgeCategory.scholar
        : BadgeCategory.explorer;

    final threshold = json['threshold'] as int? ?? 0;

    // Construct sublabel based on category and threshold
    String sublabel = '';
    if (category == BadgeCategory.explorer) {
      sublabel = 'Visit $threshold landmark${threshold == 1 ? '' : 's'}';
    } else {
      sublabel = '$threshold quiz pts';
    }

    return BadgeConfig(
      label: json['title'] as String? ?? 'Unknown',
      sublabel: sublabel,
      category: category,
      isLocked: !(json['is_unlocked'] as bool? ?? true),
      imgPath: json['img_path'] as String?,
      threshold: threshold,
      tier: (json['tier'] as num?)?.toInt(),
      description: json['description'] as String?,
      funFact: json['fun_fact'] as String?,
    );
  }
}
