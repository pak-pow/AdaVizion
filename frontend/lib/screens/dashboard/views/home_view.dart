import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../services/api/profile_api.dart';
import '../widgets/badges_card.dart';

// ============================================================================
// DASHBOARD HOME VIEW  (Consolidated)
//
// One scrollable feed showing:
//   1. Profile card  (with edit mode + avatar upload)
//   2. Badge carousel  (BadgesCard — self-contained state)
//   3. Scholar milestone progress bar
//   4. Exploration + XP progress bars
//   5. 2×2 stat grid
//
// Progress data is co-fetched with profile from GET /students/me so both
// datasets share a single network round-trip.
//
// Progress UI migrated from the now-deleted progress_view.dart.
// ============================================================================

class DashboardHomeView extends StatefulWidget {
  const DashboardHomeView({super.key});

  @override
  State<DashboardHomeView> createState() => _DashboardHomeViewState();
}

class _DashboardHomeViewState extends State<DashboardHomeView> {
  // ── Loading / edit flags ──────────────────────────────────────────────────
  bool _isLoading = true;
  bool _isUploadingPicture = false;
  bool _isEditMode = false;

  /// Current profile picture URL (Supabase), or null if not set.
  String? _imgPath;

  // ── Text controllers ──────────────────────────────────────────────────────
  final _nameController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _courseController = TextEditingController();
  final _specializationController = TextEditingController();

  // ── Progress state (GET /students/me → data['progress']) ─────────────────
  int _level = 0;
  int _quizPoints = 0;
  int _toNextLevel = 0;
  int _nextThreshold = 500;
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

  @override
  void dispose() {
    _nameController.dispose();
    _studentIdController.dispose();
    _courseController.dispose();
    _specializationController.dispose();
    super.dispose();
  }

  // ─── Data fetch ─────────────────────────────────────────────────────────────
  // Single API call populates both profile info AND all progress stats.
  Future<void> _fetchProfile() async {
    try {
      final data = await ProfileApi.getProfile();

      if (mounted) {
        setState(() {
          // ── Profile / identity fields ───────────────────────────────────
          final info = data['info'];
          if (info != null) {
            final firstName = info['first_name'] ?? '';
            final lastName = info['last_name'] ?? '';
            _nameController.text = '$firstName $lastName'.trim();
            _studentIdController.text = info['student_number'] ?? '';
            _courseController.text = info['program'] ?? '';
            _specializationController.text = info['specialization'] ?? '';
            final rawImgPath = info['img_path'];
            _imgPath = (rawImgPath is String && rawImgPath.isNotEmpty)
                ? rawImgPath
                : null;
          }

          // ── Progress fields (migrated from ProgressDashboardView) ───────
          final progress = data['progress'];
          if (progress != null) {
            final xp = progress['xp'] as Map<String, dynamic>?;
            final landmarks = progress['landmarks'] as Map<String, dynamic>?;
            _level = (progress['level'] as num?)?.toInt() ?? 0;
            _quizPoints = (progress['quiz_points'] as num?)?.toInt() ?? 0;
            _toNextLevel = (xp?['to_next_level'] as num?)?.toInt() ?? 0;
            _nextThreshold =
                (xp?['next_threshold'] as num?)?.toInt() ?? 500;
            _landmarksVisited =
                (landmarks?['visited'] as num?)?.toInt() ?? 0;
            _landmarksTotal =
                (landmarks?['total'] as num?)?.toInt() ?? 1;
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // Always reset loading so the UI never gets stuck on a spinner,
      // even if the widget was disposed before the catch block ran.
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── Profile picture upload ──────────────────────────────────────────────────
  /// Opens the device gallery, uploads the selected image via Multer, then
  /// refreshes the profile so the new Supabase URL is reflected immediately.
  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage == null) return;

    setState(() => _isUploadingPicture = true);
    try {
      await ProfileApi.uploadProfilePicture(pickedImage);
      await _fetchProfile();
      if (mounted) setState(() => _isEditMode = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture updated!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingPicture = false);
    }
  }

  // ─── Progress helpers ────────────────────────────────────────────────────────
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

  // ─── Build ──────────────────────────────────────────────────────────────────
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
          // ── 1. Profile card + Badges ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 0),
            child: Column(
              children: [
                _buildMainProfileCard(),

                AnimatedSize(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeInOutCubic,
                  child: SizedBox(height: _isEditMode ? 0 : 16),
                ),

                AnimatedOpacity(
                  opacity: _isEditMode ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 350),
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeInOutCubic,
                    alignment: Alignment.topCenter,
                    child: _isEditMode
                        ? const SizedBox(width: double.infinity, height: 0)
                        : const BadgesCard(),
                  ),
                ),
              ],
            ),
          ),

          // ── 2. Progress sections (hidden during profile edit mode) ───────
          if (!_isEditMode) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildMilestoneCard(),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildProgressCard(),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildStatGrid(),
            ),
          ],

          // Bottom clearance above the BottomAppBar + FAB.
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  // ==========================================================================
  // CARD 1: MAIN PROFILE CARD
  // ==========================================================================
  Widget _buildMainProfileCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_gradientTop, _maroon],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildProfileHeader(),
          AnimatedSize(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOutCubic,
            alignment: Alignment.topCenter,
            child: _isEditMode
                ? _buildEditForm()
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Tappable avatar (active only in edit mode) ──────────────────
        GestureDetector(
          onTap: (_isUploadingPicture || !_isEditMode)
              ? null
              : _pickAndUploadImage,
          child: SizedBox(
            width: 72,
            height: 72,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    image: (_imgPath != null)
                        ? DecorationImage(
                            image: NetworkImage(_imgPath!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: (_imgPath == null)
                      ? const Icon(
                          Icons.broken_image_outlined,
                          color: Colors.black87,
                          size: 36,
                        )
                      : null,
                ),
                if (_isUploadingPicture)
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    ),
                  )
                else if (_isEditMode)
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: Colors.black45,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(Icons.camera_alt, color: Colors.white, size: 30),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                _studentIdController.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _nameController.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _courseController.text,
                style: const TextStyle(color: Colors.white, fontSize: 10, height: 1.2),
              ),
              Text(
                _specializationController.text,
                style: const TextStyle(color: Colors.white, fontSize: 10, height: 1.2),
              ),
            ],
          ),
        ),

        // ── Edit pencil toggle ─────────────────────────────────────────
        GestureDetector(
          onTap: () => setState(() => _isEditMode = !_isEditMode),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 1.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isEditMode ? Icons.close : Icons.edit,
              color: Colors.white,
              size: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        const Center(
          child: Text(
            'Edit Profile',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildEditField(controller: _nameController, hint: 'Fullname'),
        _buildEditField(
          controller: _studentIdController,
          hint: 'Student Id',
          readOnly: true,
        ),
        _buildEditField(controller: _courseController, hint: 'Course/Program'),
        _buildEditField(
          controller: _specializationController,
          hint: 'Specialization',
        ),
        const SizedBox(height: 16),
        const Center(
          child: Text(
            'Click to save changes',
            style: TextStyle(color: Colors.white, fontSize: 11),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: ElevatedButton(
            onPressed: () {
              setState(() => _isEditMode = false);
              // TODO: Add backend API call here
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: _maroon,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: const Size(100, 36),
              elevation: 0,
            ),
            child: const Text(
              'Confirm',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditField({
    required TextEditingController controller,
    required String hint,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: SizedBox(
        height: 40,
        child: TextField(
          controller: controller,
          readOnly: readOnly,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 0,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // PROGRESS SECTION BUILDERS
  // Migrated from the now-deleted progress_view.dart.
  // ==========================================================================

  Widget _buildMilestoneCard() {
    final next = _nextMilestone;
    final allDone = next == null;
    final heading = allDone
        ? 'All Scholar badges earned! 🎉'
        : '${next.pts - _quizPoints} pts to reach ${next.rank}';
    final subtext = allDone
        ? "You've mastered every milestone."
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
            subtitle: '$xpEarned/$_nextThreshold XP · $_toNextLevel to next',
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

  Widget _buildStatGrid() {
    final scholarsEarned =
        _scholarMilestones.where((m) => _quizPoints >= m.pts).length;
    final explorersEarned =
        _explorerMilestones.where((t) => _landmarksVisited >= t).length;

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
