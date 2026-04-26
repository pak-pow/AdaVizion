import 'package:flutter/material.dart';
import '../../../services/api/profile_api.dart';
import '../widgets/badges_card.dart';
import '../../../utils/toast_service.dart';

// ============================================================================
// DASHBOARD HOME VIEW  (Consolidated + Hero Card)
//
// Scrollable feed:
//   1. Combined Hero Card  — Avatar · Name · Program / Points · Rank · Level
//   2. Badge carousel      — BadgesCard (self-contained state)
//   3. Scholar milestone card
//   4. Exploration + XP progress bars
//   5. 2×2 stat grid
//
// Profile + progress data are co-fetched from GET /students/me in a single
// round-trip.  Edit state (controllers, _isEditMode) lives in SettingsView.
// ============================================================================

class DashboardHomeView extends StatefulWidget {
  const DashboardHomeView({super.key});

  @override
  State<DashboardHomeView> createState() => _DashboardHomeViewState();
}

class _DashboardHomeViewState extends State<DashboardHomeView> {
  // ── Loading ───────────────────────────────────────────────────────────────
  bool _isLoading = true;

  // ── Display-only profile fields ───────────────────────────────────────────
  String _name = '';
  String _studentNumber = '';
  String _program = '';
  String _specialization = '';
  String? _imgPath;

  // ── Progress state (GET /students/me → data['progress']) ─────────────────
  int _level = 0;
  int _quizPoints = 0;
  int _toNextLevel = 0;
  int _landmarksVisited = 0;
  int _landmarksTotal = 1;

  // ── Brand colours ─────────────────────────────────────────────────────────
  static const _maroon = Color(0xFF7A1D1D);
  static const _gradientTop = Color(0xFFA62121);
  static const _gold = Color(0xFFFFB300);
  static const _amber = Color(0xFFE8A87C);
  static const _green = Color(0xFF2E7D32);

  // ── Scholar / Explorer milestones — mirror backend achievements.data.json ─
  static const _scholarMilestones = [
    (pts: 50, rank: 'Envergan Aspirant'),
    (pts: 100, rank: 'Wildcat Seeker'),
    (pts: 150, rank: 'Luzonian Paragon'),
  ];
  static const _explorerMilestones = [1, 5, 10];

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  // ─── Data fetch ──────────────────────────────────────────────────────────────
  Future<void> _fetchProfile() async {
    try {
      final data = await ProfileApi.getProfile();

      if (mounted) {
        setState(() {
          final info = data['info'];
          if (info != null) {
            final firstName = info['first_name'] ?? '';
            final lastName = info['last_name'] ?? '';
            _name = '$firstName $lastName'.trim();
            _studentNumber = info['student_number'] ?? '';
            _program = info['program'] ?? '';
            _specialization = info['specialization'] ?? '';
            final rawImgPath = info['img_path'];
            _imgPath = (rawImgPath is String && rawImgPath.isNotEmpty)
                ? rawImgPath
                : null;
          }

          final progress = data['progress'];
          if (progress != null) {
            final xp = progress['xp'] as Map<String, dynamic>?;
            final landmarks = progress['landmarks'] as Map<String, dynamic>?;
            _level = (progress['level'] as num?)?.toInt() ?? 0;
            _quizPoints = (progress['quiz_points'] as num?)?.toInt() ?? 0;
            _toNextLevel = (xp?['to_next_level'] as num?)?.toInt() ?? 0;
            _landmarksVisited = (landmarks?['visited'] as num?)?.toInt() ?? 0;
            _landmarksTotal = (landmarks?['total'] as num?)?.toInt() ?? 1;
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ToastService.showError(
          context,
          e.toString().replaceFirst('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── Progress helpers ─────────────────────────────────────────────────────
  ({int pts, String rank})? get _nextMilestone {
    for (final m in _scholarMilestones) {
      if (_quizPoints < m.pts) return m;
    }
    return null;
  }

  double get _scholarProgress {
    final next = _nextMilestone;
    if (next == null) return 1.0;
    final idx = _scholarMilestones.indexWhere((m) => m.pts == next.pts);
    final floor = idx > 0 ? _scholarMilestones[idx - 1].pts : 0;
    return ((_quizPoints - floor) / (next.pts - floor)).clamp(0.0, 1.0);
  }

  String get _currentRank {
    if (_landmarksVisited == 0) return 'Locked';
    String rank = 'Envergan Scout';
    for (final m in _scholarMilestones) {
      if (_quizPoints >= m.pts) rank = m.rank;
    }
    return rank;
  }

  double get _explorerProgress => _landmarksTotal > 0
      ? (_landmarksVisited / _landmarksTotal).clamp(0.0, 1.0)
      : 0.0;

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: _maroon));
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── 0. Combined Hero Card (Identity) ──────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: _buildCombinedHeroCard(),
          ),
          const SizedBox(height: 20),

          // ── 1. Badge Carousel (Achievements) ─────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: BadgesCard(
              quizPoints: _quizPoints,
              landmarksVisited: _landmarksVisited,
            ),
          ),
          const SizedBox(height: 20),

          // ── 2. Student Stats (Compact Layout) ──────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildCompactStats(),
          ),

          // Bottom clearance above BottomAppBar + FAB.
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  // ==========================================================================
  // COMBINED HERO CARD
  //
  // Top section : Avatar · Name · Program/Course  (no edit icon, no student ID)
  // Divider     : Faint white hairline
  // Bottom row  : Gold Rank chip · "X Points" counter · "Level X · Y XP total"
  // ==========================================================================
  Widget _buildCombinedHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_gradientTop, _maroon],
        ),
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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row: Avatar + Name + Program ─────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.60),
                    width: 2,
                  ),
                  image: _imgPath != null
                      ? DecorationImage(
                          image: NetworkImage(_imgPath!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _imgPath == null
                    ? const Icon(
                        Icons.person_outline,
                        color: Colors.white,
                        size: 32,
                      )
                    : null,
              ),
              const SizedBox(width: 20),

              // Name + Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _name.isEmpty ? 'Student' : _name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                    if (_studentNumber.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        _studentNumber,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          height: 1.1,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    if (_program.isNotEmpty)
                      Text(
                        _program,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    if (_specialization.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        _specialization,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Rank chip (Moved to top-right)
              _buildRankChip(),
            ],
          ),
        ],
      ),
    );
  }

  // Extracted Rank Chip for relocation
  Widget _buildRankChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _landmarksVisited == 0
            ? Colors.transparent
            : _gold.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _landmarksVisited == 0
              ? Colors.white.withValues(alpha: 0.4)
              : _gold.withValues(alpha: 0.55),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _landmarksVisited == 0
                ? Icons.lock_outline_rounded
                : Icons.military_tech_rounded,
            color: _landmarksVisited == 0
                ? Colors.white.withValues(alpha: 0.4)
                : _gold,
            size: 13,
          ),
          const SizedBox(width: 4),
          Text(
            _currentRank,
            style: TextStyle(
              color: _landmarksVisited == 0
                  ? Colors.white.withValues(alpha: 0.4)
                  : _gold,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // PROGRESS SECTION BUILDERS
  // ==========================================================================

  // ==========================================================================
  // COMPACT STATS SECTION
  // ==========================================================================

  Widget _buildCompactStats() {
    final currentXP = (500 - _toNextLevel).clamp(0, 500);
    final xpProgress = currentXP / 500.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. XP & Level Progress (Top Row)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Level $_level',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  Text(
                    '$currentXP / 500 XP',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildAnimatedBar(xpProgress, _green, Colors.grey.shade200),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 2. Landmarks & Quiz Row (Bottom Row)
        Row(
          children: [
            Expanded(
              child: _buildCompactStatCard(
                label: 'Landmarks',
                value: 'Visited: $_landmarksVisited/$_landmarksTotal',
                icon: Icons.explore_outlined,
                color: _amber,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildCompactStatCard(
                label: 'Quiz Scores',
                value: '$_quizPoints Total Quiz Points',
                icon: Icons.percent_rounded,
                color: _maroon,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompactStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
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
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBar(double progress, Color fill, Color bg) {
    return LayoutBuilder(
      builder: (context, constraints) => Container(
        height: 7,
        width: constraints.maxWidth,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOutCubic,
            builder: (context, val, child) => FractionallySizedBox(
              widthFactor: val.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: fill,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
