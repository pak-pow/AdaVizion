import 'package:flutter/material.dart';
import '../../../services/api/profile_api.dart';

// ============================================================================
// PROGRESS / SCORING DASHBOARD VIEW
//
// Extracted from dashboard_screen.dart (lines 1053–1743).
// Renamed: QuizScoresPlaceholder → ProgressDashboardView.
//
// Data source: GET /students/me (ProfileApi.getProfile)
//   progress.quiz_points      → Hero metric & Scholar badge currency
//   progress.level            → Current student level
//   progress.xp.total_xp      → Total exploration XP
//   progress.xp.to_next_level → XP gap to next level
//   progress.xp.next_threshold→ XP for next level boundary
//   progress.landmarks.visited→ Explorer badge currency
//   progress.landmarks.total  → Total landmark count
//
// Scholar milestones (from achievements.data.json):
//   50 pts  → "Envergan Aspirant"
//   100 pts → "Wildcat Seeker"
//   150 pts → "Luzonian Paragon"
// ============================================================================

class ProgressDashboardView extends StatefulWidget {
  const ProgressDashboardView({super.key});

  @override
  State<ProgressDashboardView> createState() => _ProgressDashboardViewState();
}

class _ProgressDashboardViewState extends State<ProgressDashboardView>
    with SingleTickerProviderStateMixin {
  // ─── Brand colours ────────────────────────────────────────────────────────
  static const _maroon = Color(0xFF7A1D1D);
  static const _maroonDark = Color(0xFF4A0F0F);
  static const _gold = Color(0xFFFFB300);
  static const _amber = Color(0xFFE8A87C);
  static const _green = Color(0xFF2E7D32);

  // Scholar milestones — matches backend achievements.data.json.
  static const _scholarMilestones = [
    (pts: 50, rank: 'Envergan Aspirant'),
    (pts: 100, rank: 'Wildcat Seeker'),
    (pts: 150, rank: 'Luzonian Paragon'),
  ];

  // Explorer milestones — matches backend achievements.data.json.
  static const _explorerMilestones = [1, 5, 10];

  bool _isLoading = true;
  String? _error;

  // Progress data populated from GET /students/me
  int _level = 0;
  int _quizPoints = 0;
  int _totalXp = 0;
  int _toNextLevel = 0;
  int _nextThreshold = 500;
  int _landmarksVisited = 0;
  int _landmarksTotal = 0;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOutCubic,
    );
    _fetchScoringData();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // ─── Data fetch ───────────────────────────────────────────────────────────
  Future<void> _fetchScoringData() async {
    try {
      final data = await ProfileApi.getProfile();
      final progress = data['progress'];

      if (progress != null && mounted) {
        final xp = progress['xp'] as Map<String, dynamic>?;
        final landmarks = progress['landmarks'] as Map<String, dynamic>?;

        setState(() {
          _level = (progress['level'] as num?)?.toInt() ?? 0;
          _quizPoints = (progress['quiz_points'] as num?)?.toInt() ?? 0;
          _totalXp = (xp?['total_xp'] as num?)?.toInt() ?? 0;
          _toNextLevel = (xp?['to_next_level'] as num?)?.toInt() ?? 0;
          _nextThreshold = (xp?['next_threshold'] as num?)?.toInt() ?? 500;
          _landmarksVisited = (landmarks?['visited'] as num?)?.toInt() ?? 0;
          _landmarksTotal = (landmarks?['total'] as num?)?.toInt() ?? 1;
          _isLoading = false;
        });

        _animController
          ..reset()
          ..forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  // ─── Scholar helpers ──────────────────────────────────────────────────────

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
    String rank = 'Envergan Scout';
    for (final m in _scholarMilestones) {
      if (_quizPoints >= m.pts) rank = m.rank;
    }
    return rank;
  }

  double get _explorerProgress => _landmarksTotal > 0
      ? (_landmarksVisited / _landmarksTotal).clamp(0.0, 1.0)
      : 0.0;

  double get _xpLevelProgress {
    if (_nextThreshold <= 0) return 0.0;
    return ((_nextThreshold - _toNextLevel) / _nextThreshold).clamp(0.0, 1.0);
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F6),
      appBar: AppBar(
        backgroundColor: _maroon,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Progress',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _maroon))
          : _error != null
          ? _buildError()
          : FadeTransition(
              opacity: _fadeAnim,
              child: RefreshIndicator(
                color: _maroon,
                onRefresh: _fetchScoringData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeroCard(),
                      const SizedBox(height: 14),
                      _buildMilestoneCard(),
                      const SizedBox(height: 14),
                      _buildProgressCard(),
                      const SizedBox(height: 14),
                      _buildStatGrid(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  // ─── Error state ──────────────────────────────────────────────────────────
  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, color: _maroon, size: 48),
            const SizedBox(height: 12),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54, fontSize: 13),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _fetchScoringData();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _maroon,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Hero card: Quiz Points ───────────────────────────────────────────────
  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFA62121), _maroonDark],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _maroon.withValues(alpha: 0.38),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rank chip
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _gold.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _gold.withValues(alpha: 0.60)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded, color: _gold, size: 11),
                    const SizedBox(width: 4),
                    Text(
                      _currentRank,
                      style: const TextStyle(
                        color: _gold,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Quiz Points',
                style: TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Big number
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: _quizPoints.toDouble()),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeInOutCubic,
            builder: (context, val, child) => Text(
              '${val.toInt()} Points',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 44,
                fontWeight: FontWeight.w900,
                height: 1,
                letterSpacing: -1,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Level $_level \u00B7 $_totalXp XP total',
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
        ],
      ),
    );
  }

  // ─── Milestone card ───────────────────────────────────────────────────────
  Widget _buildMilestoneCard() {
    final next = _nextMilestone;
    final allDone = next == null;

    final heading = allDone
        ? 'All Scholar badges earned! \uD83C\uDF89'
        : '${next.pts - _quizPoints} pts to reach ${next.rank}';
    final subtext = allDone
        ? 'You\'ve mastered every milestone.'
        : '$_quizPoints / ${next.pts} quiz points';

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: _gold.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.emoji_events_outlined,
                  color: _gold,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      heading,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtext,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${(_scholarProgress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: _gold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildAnimatedBar(_scholarProgress, _gold, Colors.grey.shade200),
          const SizedBox(height: 8),
          // Milestone pip labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _scholarMilestones.map((m) {
              final earned = _quizPoints >= m.pts;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    earned
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    size: 10,
                    color: earned ? _gold : Colors.grey.shade400,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '${m.pts} pts',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: earned ? _gold : Colors.grey.shade400,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ─── Explorer + XP progress card ──────────────────────────────────────────
  Widget _buildProgressCard() {
    final xpEarned = _nextThreshold - _toNextLevel;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Exploration',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 16),
          _buildProgressRow(
            icon: Icons.explore_outlined,
            iconColor: _amber,
            title: 'Landmarks',
            subtitle: 'Visited: $_landmarksVisited/$_landmarksTotal',
            progress: _explorerProgress,
            barColor: _amber,
          ),
          const SizedBox(height: 14),
          _buildProgressRow(
            icon: Icons.bolt_rounded,
            iconColor: _green,
            title: 'Level $_level',
            subtitle:
                '$xpEarned/$_nextThreshold XP \u00B7 $_toNextLevel to next',
            progress: _xpLevelProgress,
            barColor: _green,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required double progress,
    required Color barColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.13),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 15),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 9.5,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: barColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        _buildAnimatedBar(progress, barColor, Colors.grey.shade200),
      ],
    );
  }

  // ─── 2×2 Stat grid ────────────────────────────────────────────────────────
  Widget _buildStatGrid() {
    final scholarsEarned = _scholarMilestones
        .where((m) => _quizPoints >= m.pts)
        .length;
    final explorersEarned = _explorerMilestones
        .where((t) => _landmarksVisited >= t)
        .length;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.35,
      children: [
        _buildStatTile(
          icon: Icons.place_outlined,
          color: _amber,
          value: '$_landmarksVisited/$_landmarksTotal',
          label: 'Landmarks',
          sub: '$explorersEarned Explorer badges',
        ),
        _buildStatTile(
          icon: Icons.bolt_rounded,
          color: _green,
          value: 'LVL $_level',
          label: 'XP Progress',
          sub: '$_toNextLevel XP to next level',
        ),
        _buildStatTile(
          icon: Icons.percent_rounded,
          color: _maroon,
          value: '-',
          label: 'Avg. Quiz Score',
          sub: 'Coming soon',
        ),
        _buildStatTile(
          icon: Icons.military_tech_outlined,
          color: _gold,
          value: '${scholarsEarned + explorersEarned}/6',
          label: 'Rank',
          sub: _currentRank,
        ),
      ],
    );
  }

  Widget _buildStatTile({
    required IconData icon,
    required Color color,
    required String value,
    required String label,
    required String sub,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
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
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1A1A1A),
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF444444),
            ),
          ),
          Text(
            sub,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Animated progress bar ────────────────────────────────────────────────
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
