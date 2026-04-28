import 'package:flutter/material.dart';
import '../../../services/api/profile_api.dart';
import '../widgets/badges_card.dart';
import '../widgets/student_card.dart';
import '../widgets/student_stats.dart';
import '../../../utils/toast_service.dart';
import 'package:adavizion/theme/app_colors.dart';
import '../../auth/views/auth_layout_view.dart';

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
  int _currentXp = 0;
  int _xpMax = 500;  // next_threshold from backend; defaults to 500
  int _landmarksVisited = 0;
  int _landmarksTotal = 1;

  // ── Level-up detection — persisted across refreshes ───────────────────────
  int? _previousLevel;

  // ── Scholar / Explorer milestones — mirror backend achievements.data.json ─

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
            final rawProgram = info['program'] ?? '';
            _program = kBackendPrograms[rawProgram] ?? rawProgram;
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
            final newLevel = (progress['level'] as num?)?.toInt() ?? 0;
            _quizPoints = (progress['quiz_points'] as num?)?.toInt() ?? 0;
            // total_xp  = XP earned within the current level.
            // to_next_level = XP still needed to level up.
            // Level size = earned + remaining (NOT next_threshold, which is cumulative).
            final toNextLevel = (xp?['to_next_level'] as num?)?.toInt() ?? 500;
            _currentXp = (xp?['total_xp'] as num?)?.toInt() ?? 0;
            _xpMax = (_currentXp + toNextLevel)
                .clamp(1, 999999); // Guard against 0 to prevent division-by-zero.
            _landmarksVisited = (landmarks?['visited'] as num?)?.toInt() ?? 0;
            _landmarksTotal = (landmarks?['total'] as num?)?.toInt() ?? 1;

            // ── Achievement Toast: Level Up ──────────────────────────────
            // Only fire after the *first* successful fetch (_previousLevel != null)
            // to avoid a spurious toast on cold start.
            if (_previousLevel != null && newLevel > _previousLevel!) {
              // Triggered globally — no context needed. Safe from async gap.
              ToastService.showAchievement(
                'Level Up! 🎉',
                'You are now Level $newLevel!',
              );
            }
            _previousLevel = newLevel;
            _level = newLevel;
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ToastService.showError(
          e.toString().replaceFirst('Exception: ', ''),
          context,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── Progress helpers ─────────────────────────────────────────────────────

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.maroon));
    }

    return RefreshIndicator(
      color: AppColors.maroon,
      onRefresh: _fetchProfile,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── 0. Combined Hero Card (Identity) ──────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: StudentCard(
                name: _name,
                studentNumber: _studentNumber,
                program: _program,
                specialization: _specialization,
                imgPath: _imgPath,
              ),
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
              child: StudentStats(
                level: _level,
                currentXp: _currentXp,
                xpMax: _xpMax,
                landmarksVisited: _landmarksVisited,
                landmarksTotal: _landmarksTotal,
                quizPoints: _quizPoints,
              ),
            ),

            // Bottom clearance above BottomAppBar + FAB.
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // PROGRESS SECTION BUILDERS
  // ==========================================================================
}
