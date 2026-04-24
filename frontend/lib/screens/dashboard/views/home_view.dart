import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../services/api/profile_api.dart';
import '../widgets/badges_card.dart';
// qrcode_screen.dart import removed — QR navigation is now handled
// by the global center-docked FAB in DashboardScreen.

// ============================================================================
// DASHBOARD HOME VIEW
//
// Extracted from dashboard_screen.dart (lines 157–1051).
//
// This widget is the main scrollable body of the dashboard. It shows:
//   1. The profile card (with edit mode + avatar upload)
//   2. The badge carousel (BadgesCard — self-contained)
//
// State removed versus the original:
//   - _selectedBadgeFilter → moved into BadgesCard
//   - _badgeScrollController → moved into BadgesCard
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

  // ─── Brand colours ─────────────────────────────────────────────────────────
  static const _maroon = Color(0xFF7A1D1D);
  static const _gradientTop = Color(0xFFA62121);

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

  // ─── Data fetch ────────────────────────────────────────────────────────────

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

  // ─── Profile picture upload ────────────────────────────────────────────────

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

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: _maroon));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ─── TOP SECTION: Cards ─────────────────────────────────────────────
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
                      : const BadgesCard(),
                ),
              ),
            ],
          ),
        ),

        // Bottom padding gives scroll clearance above the BottomAppBar + FAB.
        const SizedBox(height: 120),
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
  // SHARED UI COMPONENTS
  // ==========================================

  Widget _buildProfileHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── TAPPABLE AVATAR ────────────────────────────────────────────────
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

        // ─── EDIT PENCIL TOGGLE ──────────────────────────────────────────────
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
