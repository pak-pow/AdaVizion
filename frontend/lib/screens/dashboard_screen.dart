import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'login_screen.dart';
import 'qrcode_screen.dart';
import 'quiz_screen.dart';
import '../services/api/api_config.dart';
import '../services/api/profile_api.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // --- BRAND COLORS ---
  static const _maroon = Color(0xFF7A1D1D);
  static const _maroonDark = Color(0xFF4A0F0F);
  static const _headerGrey = Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: _headerGrey,
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset('assets/images/nav_logo.png', height: 42),

            Row(
              children: [
                // LOG OUT
                GestureDetector(
                  onTap: _showLogoutConfirmation,
                  child: const Text(
                    'Log out',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _maroon,
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // QUIZZES
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const QuizScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _maroonDark,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    minimumSize: const Size(0, 32),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 0,
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Quizzes',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      body: SizedBox.expand(
        child: Stack(
          children: [
            const DashboardHomeView(),

            Positioned(
              bottom: -224,
              left: 0,
              right: 0,
              child: RepaintBoundary(
                child: IgnorePointer(
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 500,
                    fit: BoxFit.contain,
                    alignment: Alignment.topCenter,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── LOGOUT ─────────────────────────────────────────────────────────────────
  void _showLogoutConfirmation() {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text(
            'Log out?',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: const Text('Are you sure you want to log out of EUventure?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Close dialog first
                await ApiConfig.logout(); // Clear JWT from shared_preferences
                if (mounted) {
                  // Replace the entire navigation stack — the back button
                  // cannot return to the dashboard after logout.
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const AuthScreen()),
                    (route) => false,
                  );
                }
              },
              child: const Text(
                'Log out',
                style: TextStyle(color: _maroon, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ============================================================================
// THE DASHBOARD / PROFILE VIEW
// ============================================================================
class DashboardHomeView extends StatefulWidget {
  const DashboardHomeView({super.key});

  @override
  State<DashboardHomeView> createState() => _DashboardHomeViewState();
}

class _DashboardHomeViewState extends State<DashboardHomeView> {
  bool _isLoading = true;

  /// True while an image upload is in progress. Overlays a spinner on the avatar.
  bool _isUploadingPicture = false;

  /// True when the user has tapped the pencil icon to enter edit mode.
  /// In this mode, tapping the avatar opens the image picker and a camera
  /// overlay is shown to signal interactability.
  bool _isEditMode = false;

  /// Which badge category filter is currently active.
  /// null = All, otherwise the specific category.
  _BadgeCategory? _selectedBadgeFilter;

  /// Controller for the horizontal badge carousel.
  final _badgeScrollController = ScrollController();

  /// The current profile picture URL from Supabase, or null if not set.
  String? _imgPath;

  final _nameController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _courseController = TextEditingController();
  final _specializationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final data = await ProfileApi.getProfile();

      if (mounted) {
        setState(() {
          final info = data['info'];

          if (info != null) {
            final firstName = info['first_name'] ?? '';
            final lastName = info['last_name'] ?? '';

            _nameController.text = '$firstName $lastName'.trim();
            _studentIdController.text = info['student_number'] ?? '';
            _courseController.text = info['program'] ?? '';
            _specializationController.text = info['specialization'] ?? '';

            // Capture the Supabase image URL (may be null if never uploaded).
            final rawImgPath = info['img_path'];
            _imgPath = (rawImgPath is String && rawImgPath.isNotEmpty)
                ? rawImgPath
                : null;
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
      // Always reset the loading state so the UI never gets stuck on a spinner,
      // even if the widget was disposed before the catch block's mounted check ran.
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── PICK & UPLOAD PROFILE PICTURE ──────────────────────────────────────────

  /// Opens the device gallery, uploads the selected image via Multer, then
  /// refreshes the profile so the new Supabase URL is reflected immediately.
  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    // User cancelled the picker — nothing to do.
    if (pickedImage == null) return;

    setState(() => _isUploadingPicture = true);

    try {
      // Pass the XFile directly — no dart:io File() wrapper needed.
      // ProfileApi.uploadProfilePicture now reads bytes via XFile.readAsBytes(),
      // which is supported on Web, Android, and iOS.
      await ProfileApi.uploadProfilePicture(pickedImage);

      // Seamlessly refresh the avatar with the new Supabase-hosted URL.
      await _fetchProfile();

      // Auto-exit edit mode now that the upload has completed successfully.
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
      // Always lift the upload overlay, even if the widget was disposed.
      if (mounted) setState(() => _isUploadingPicture = false);
    }
  }

  static const _maroon = Color(0xFF7A1D1D);
  static const _gradientTop = Color(0xFFA62121);

  @override
  void dispose() {
    _nameController.dispose();
    _studentIdController.dispose();
    _courseController.dispose();
    _specializationController.dispose();
    _badgeScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: _maroon));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ─── TOP SECTION: Cards ───────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 0),
          child: Column(
            children: [
              // 1. MAIN PROFILE CARD
              _buildMainProfileCard(),

              AnimatedSize(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOutCubic,
                child: SizedBox(height: _isEditMode ? 0 : 16),
              ),

              // 2. BADGES CARD
              AnimatedOpacity(
                opacity: _isEditMode ? 0.0 : 1.0,
                // Synced to 350ms so the fade matches the AnimatedSize accordion
                // on the profile card — they disappear and reappear together.
                duration: const Duration(milliseconds: 350),
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeInOutCubic,
                  alignment: Alignment.topCenter,
                  child: _isEditMode
                      ? const SizedBox(width: double.infinity, height: 0)
                      : _buildBadgesCard(),
                ),
              ),
            ],
          ),
        ),

        // ─── BOTTOM SECTION: SCAN NOW ────────────────────────────────────
        // Expands to fill remaining screen space so the QR prompt sits
        // centred below the cards without the page needing to scroll.
        // Hidden entirely during edit mode to remove the empty gap.
        if (!_isEditMode)
          Expanded(
            child: IgnorePointer(
              ignoring: _isEditMode,
              child: AnimatedOpacity(
                opacity: _isEditMode ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 650),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Scan now!',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: _maroon,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'to unlock quizzes and explore\nEnverga University',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _maroon,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // FUNCTIONAL: QR Code Scanner Button
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const QRCodeScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(color: _maroon, width: 2.0),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.qr_code_2,
                          size: 60,
                          color: _maroon,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        const SizedBox(height: 160),
      ],
    );
  }

  // ==========================================
  // CARD 1: MAIN PROFILE CARD
  // ==========================================
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
          topLeft: Radius.circular(0),
          topRight: Radius.circular(0),
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

  // ==========================================
  // CARD 2: BADGES CARD
  // ==========================================

  // The backend `Achievement` model has 6 seeded entries across two categories:
  //   EXPLORER (landmark-based): Envergan Scout, Wildcat Voyager, Luzonian Trailblazer
  //   SCHOLAR  (quiz-point-based): Envergan Aspirant, Wildcat Seeker, Luzonian Paragon
  // Each achievement has: achievement_id, title, description, category, threshold, img_path.
  // Badges are locked until the student reaches the achievement's threshold.
  static const _achievementBadges = [
    _BadgeConfig(
      label: 'Scout',
      sublabel: 'Visit 1 landmark',
      category: _BadgeCategory.explorer,
      isLocked: true,
    ),
    _BadgeConfig(
      label: 'Voyager',
      sublabel: 'Visit 5 landmarks',
      category: _BadgeCategory.explorer,
      isLocked: true,
    ),
    _BadgeConfig(
      label: 'Trailblazer',
      sublabel: 'Visit all landmarks',
      category: _BadgeCategory.explorer,
      isLocked: true,
    ),
    _BadgeConfig(
      label: 'Aspirant',
      sublabel: '50 quiz pts',
      category: _BadgeCategory.scholar,
      isLocked: true,
    ),
    _BadgeConfig(
      label: 'Seeker',
      sublabel: '100 quiz pts',
      category: _BadgeCategory.scholar,
      isLocked: true,
    ),
    _BadgeConfig(
      label: 'Paragon',
      sublabel: '150 quiz pts',
      category: _BadgeCategory.scholar,
      isLocked: true,
    ),
  ];

  Widget _buildBadgesCard() {
    // Filtered list drives the carousel.
    final visibleBadges = _selectedBadgeFilter == null
        ? _achievementBadges
        : _achievementBadges
              .where((b) => b.category == _selectedBadgeFilter)
              .toList();

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
                      builder: (context) => const QuizScoresPlaceholder(),
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
                isActive: _selectedBadgeFilter == _BadgeCategory.explorer,
                activeColor: const Color(0xFFE8A87C),
                onTap: () => setState(() {
                  _selectedBadgeFilter = _BadgeCategory.explorer;
                  _badgeScrollController.jumpTo(0);
                }),
              ),
              const SizedBox(width: 8),
              _buildFilterTab(
                label: 'Scholar',
                icon: Icons.school_outlined,
                isActive: _selectedBadgeFilter == _BadgeCategory.scholar,
                activeColor: const Color(0xFFFFD700),
                onTap: () => setState(() {
                  _selectedBadgeFilter = _BadgeCategory.scholar;
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
                itemCount: visibleBadges.length,
                separatorBuilder: (_, _) => const SizedBox(width: 14),
                itemBuilder: (_, i) =>
                    _buildBadgePlaceholder(config: visibleBadges[i]),
              ),
            ),
          ),

          // ── Row 4: Scroll hint dots ────────────────────────────────────────
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

  /// Renders a single coin-shaped achievement badge for the carousel.
  ///
  /// Locked  → grey gradient + semi-transparent lock icon
  /// Unlocked → category-tinted gradient + category icon
  Widget _buildBadgePlaceholder({required _BadgeConfig config}) {
    const double size = 72;

    final List<Color> gradient;
    final Color iconColor;
    final IconData icon;

    if (config.isLocked) {
      gradient = [Colors.grey.shade300, Colors.grey.shade400];
      iconColor = Colors.white.withValues(alpha: 0.70);
      icon = Icons.lock_outline_rounded;
    } else if (config.category == _BadgeCategory.explorer) {
      gradient = [const Color(0xFFE8A87C), const Color(0xFFC0703A)];
      iconColor = Colors.white;
      icon = Icons.explore_outlined;
    } else {
      gradient = [const Color(0xFFFFE066), const Color(0xFFFFB300)];
      iconColor = Colors.white;
      icon = Icons.school_outlined;
    }

    // Category accent colour for the small label chip.
    final chipColor = config.category == _BadgeCategory.explorer
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

  // ==========================================
  // SHARED UI COMPONENTS
  // ==========================================

  Widget _buildProfileHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── TAPPABLE AVATAR ──────────────────────────────────────────────
        // GestureDetector is only active when _isEditMode is true, preventing
        // accidental picks. A camera overlay signals interactability in edit
        // mode; a spinner overlay replaces it during an active upload.
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
                // ── AVATAR CIRCLE ──
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
                  // Show the placeholder icon only when no image is available.
                  child: (_imgPath == null)
                      ? const Icon(
                          Icons.broken_image_outlined,
                          color: Colors.black87,
                          size: 36,
                        )
                      : null,
                ),

                // ── UPLOAD SPINNER OVERLAY ── (shown during active upload)
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
                // ── CAMERA OVERLAY ── (shown in edit mode, not while uploading)
                else if (_isEditMode)
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: Colors.black45,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 30,
                      ),
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
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  height: 1.2,
                ),
              ),
              Text(
                _specializationController.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),

        // ─── EDIT PENCIL TOGGLE ───────────────────────────────────────────
        // Toggles _isEditMode. Icon switches to 'close' when active so the
        // user has a clear way to cancel without uploading.
        GestureDetector(
          onTap: () {
            setState(() => _isEditMode = !_isEditMode);
          },
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

        // FUNCTIONAL: Confirm Edit Button
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
}

// ============================================================================
// SCORING DASHBOARD SCREEN
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

class QuizScoresPlaceholder extends StatefulWidget {
  const QuizScoresPlaceholder({super.key});

  @override
  State<QuizScoresPlaceholder> createState() => _QuizScoresDashboardState();
}

class _QuizScoresDashboardState extends State<QuizScoresPlaceholder>
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

// ============================================================================
// BADGE DATA TYPES
// Mirrors the backend AchievementCategory enum (EXPLORER | SCHOLAR).
// ============================================================================

/// Maps to the backend `AchievementCategory` Prisma enum.
enum _BadgeCategory { explorer, scholar }

/// Lightweight config for a single badge coin in the carousel UI.
/// [sublabel] surfaces the threshold condition from the seed data.
/// When real API data is wired, replace `isLocked` with a live earned check.
class _BadgeConfig {
  final String label;
  final String sublabel;
  final _BadgeCategory category;
  final bool isLocked;

  const _BadgeConfig({
    required this.label,
    required this.sublabel,
    required this.category,
    required this.isLocked,
  });
}
