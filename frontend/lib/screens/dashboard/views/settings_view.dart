import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../services/api/api_config.dart';
import '../../../services/api/profile_api.dart';
import '../../login_screen.dart';

// ============================================================================
// SETTINGS VIEW  (Profile & Settings — tab 3)
//
// Header  — "Profile" title + settings gear
// Banner  — Detailed card: Avatar, Full Name, Student Number,
//           Course, Specialisation, + pencil edit toggle
// Edit    — Accordion form that expands below the banner card in-place
// Account — Edit Profile (opens accordion), Notifications*, Privacy*
// App     — App Version v1.0.0
// Session — Log Out (maroon, confirmation dialog)
//
// Edit state migrated from DashboardHomeView:
//   _isEditMode, _isUploadingPicture, 4 × TextEditingControllers
// ============================================================================

class SettingsView extends StatefulWidget {
  const SettingsView({super.key, required this.onEditProfile});

  /// Called when "Edit Profile" tile is tapped as a shortcut.
  /// The accordion on this screen is the primary edit entry point.
  final VoidCallback onEditProfile;

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  // ── Brand colours ─────────────────────────────────────────────────────────
  static const _maroon = Color(0xFF7A1D1D);
  static const _gradientTop = Color(0xFFA62121);

  // ── Loading ───────────────────────────────────────────────────────────────
  bool _isLoading = true;

  // ── Edit state (migrated from DashboardHomeView) ──────────────────────────
  bool _isEditMode = false;
  bool _isUploadingPicture = false;

  // ── Display / editable fields ─────────────────────────────────────────────
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
            final rawImg = info['img_path'];
            _imgPath =
                (rawImg is String && rawImg.isNotEmpty) ? rawImg : null;
          }
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── Avatar upload ─────────────────────────────────────────────────────────
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

  // ─── Logout ────────────────────────────────────────────────────────────────
  void _showLogoutDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'Log out?',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        content: const Text(
          'Are you sure you want to log out of EUventure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await ApiConfig.logout();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const AuthScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text(
              'Log out',
              style: TextStyle(
                color: _maroon,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Feature coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // ─── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _maroon))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── Detailed profile banner + optional edit form ──
                        _buildDetailedProfileBanner(),

                        // ── Edit accordion ────────────────────────────────
                        AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOutCubic,
                          alignment: Alignment.topCenter,
                          child: _isEditMode
                              ? _buildEditForm()
                              : const SizedBox(width: double.infinity),
                        ),

                        const SizedBox(height: 28),

                        // ── Account section ──────────────────────────────
                        _buildSectionLabel('Account'),
                        _buildSettingsGroup([
                          _buildTile(
                            icon: Icons.notifications_outlined,
                            label: 'Notifications',
                            onTap: _showComingSoon,
                          ),
                          _buildTile(
                            icon: Icons.lock_outline,
                            label: 'Privacy & Security',
                            onTap: _showComingSoon,
                          ),
                        ]),

                        const SizedBox(height: 20),

                        // ── App section ──────────────────────────────────
                        _buildSectionLabel('App'),
                        _buildSettingsGroup([
                          _buildTile(
                            icon: Icons.info_outline,
                            label: 'App Version',
                            showArrow: false,
                            trailing: Text(
                              'v1.0.0',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ]),

                        const SizedBox(height: 20),

                        // ── Session section ──────────────────────────────
                        _buildSectionLabel('Session'),
                        _buildSettingsGroup([
                          _buildTile(
                            icon: Icons.logout,
                            label: 'Log Out',
                            iconColor: _maroon,
                            labelColor: _maroon,
                            showArrow: false,
                            onTap: _showLogoutDialog,
                          ),
                        ]),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      color: const Color(0xFFF7F7F9),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Profile',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1A1A1A),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.settings_outlined,
              size: 20,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }

  // ── Detailed profile banner ────────────────────────────────────────────────
  // Shows: Avatar, Full Name, Student Number, Course, Specialisation.
  // Pencil icon top-right toggles _isEditMode.
  Widget _buildDetailedProfileBanner() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_gradientTop, _maroon],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _maroon.withValues(alpha: 0.28),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Tappable avatar (only in edit mode) ──────────────────
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
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // ── Name + student ID + course + specialisation ───────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 2),
                    Text(
                      _nameController.text.isEmpty
                          ? 'Student'
                          : _nameController.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                      ),
                    ),
                    if (_studentIdController.text.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        _studentIdController.text,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                    if (_courseController.text.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        _courseController.text,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.80),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    if (_specializationController.text.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        _specializationController.text,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.65),
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // ── Edit pencil toggle ────────────────────────────────────
              GestureDetector(
                onTap: () => setState(() => _isEditMode = !_isEditMode),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.45),
                      width: 1.2,
                    ),
                  ),
                  child: Icon(
                    _isEditMode ? Icons.close : Icons.edit,
                    color: Colors.white,
                    size: 15,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Edit accordion ─────────────────────────────────────────────────────────
  // Slides open below the profile banner when _isEditMode is true.
  Widget _buildEditForm() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Edit Profile',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 16),
          _buildEditField(controller: _nameController, hint: 'Full Name'),
          _buildEditField(
            controller: _studentIdController,
            hint: 'Student ID',
            readOnly: true,
          ),
          _buildEditField(
            controller: _courseController,
            hint: 'Course / Program',
          ),
          _buildEditField(
            controller: _specializationController,
            hint: 'Specialization',
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _isEditMode = false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade600,
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() => _isEditMode = false);
                    // TODO: Add backend PATCH /students/me call here
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _maroon,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditField({
    required TextEditingController controller,
    required String hint,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        style: const TextStyle(
          fontSize: 13,
          color: Color(0xFF1A1A1A),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: hint,
          labelStyle: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          filled: true,
          fillColor: readOnly
              ? Colors.grey.shade100
              : const Color(0xFFF7F7F9),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _maroon, width: 1.5),
          ),
        ),
      ),
    );
  }

  // ── Section helpers ────────────────────────────────────────────────────────
  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: Colors.grey.shade500,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> tiles) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (int i = 0; i < tiles.length; i++) ...[
            tiles[i],
            if (i < tiles.length - 1)
              const Divider(height: 1, indent: 56, endIndent: 0),
          ],
        ],
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String label,
    Color? iconColor,
    Color? labelColor,
    Widget? trailing,
    bool showArrow = true,
    VoidCallback? onTap,
  }) {
    final effectiveIconColor = iconColor ?? Colors.grey.shade700;

    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: effectiveIconColor.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: effectiveIconColor),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: labelColor ?? const Color(0xFF1A1A1A),
        ),
      ),
      trailing: trailing ??
          (showArrow
              ? Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade400,
                  size: 20,
                )
              : null),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }
}
