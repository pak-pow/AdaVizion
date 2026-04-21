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

      // Load the Dashboard view directly
      body: const DashboardHomeView(),
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: _maroon));
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // ─── DYNAMIC TOP SECTION (Cards) ──────────────────────────────────
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
                  duration: const Duration(milliseconds: 200),
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
          const SizedBox(height: 60),
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
                MaterialPageRoute(builder: (context) => const QRCodeScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: _maroon, width: 2.0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.qr_code_2, size: 60, color: _maroon),
            ),
          ),
          const SizedBox(height: 60),
        ],
      ),
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
  Widget _buildBadgesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 20, 20, 24),
      decoration: BoxDecoration(
        color: _maroon,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Badges',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 100),

          // FUNCTIONAL: Quiz Scores Button
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
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: const Text(
              'Quiz Scores',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
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
// TEMPORARY PLACEHOLDER SCREENS
// ============================================================================

class QuizScoresPlaceholder extends StatelessWidget {
  const QuizScoresPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Scores', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF7A1D1D),
      ),
      body: const Center(
        child: Text('Badges & Scores Go Here!', style: TextStyle(fontSize: 20)),
      ),
    );
  }
}
