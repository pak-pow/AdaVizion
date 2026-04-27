import 'package:flutter/material.dart';
import 'package:adavizion/theme/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import '../../../services/api/api_config.dart';
import '../../../services/api/profile_api.dart';
import '../../auth/views/auth_layout_view.dart';
import '../../login_screen.dart';
import '../../../utils/toast_service.dart';

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


  // ── Loading ───────────────────────────────────────────────────────────────
  bool _isLoading = true;

  // ── Edit state (migrated from DashboardHomeView) ──────────────────────────
  bool _isEditMode = false;
  bool _isUploadingPicture = false;

  // ── Display / editable fields ─────────────────────────────────────────────
  String? _imgPath;
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _courseController = TextEditingController();
  final _specializationController = TextEditingController();
  int _yearLevel = 1;

  String get _fullName {
    final first = _firstNameController.text.trim();
    final middle = _middleNameController.text.trim();
    final last = _lastNameController.text.trim();
    if (first.isEmpty && middle.isEmpty && last.isEmpty) return '';
    return [first, middle, last].where((s) => s.isNotEmpty).join(' ');
  }

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
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
            final middleName = info['middle_name'] ?? '';

            _firstNameController.text = firstName;
            _lastNameController.text = lastName;
            _middleNameController.text = middleName;

            // Fallback: If DB only has single string name
            final fullNameStr = info['full_name'] ?? info['name'];
            if (firstName.isEmpty &&
                lastName.isEmpty &&
                fullNameStr is String &&
                fullNameStr.isNotEmpty) {
              final parts = fullNameStr.trim().split(RegExp(r'\s+'));
              if (parts.length == 1) {
                _firstNameController.text = parts[0];
              } else if (parts.length == 2) {
                _firstNameController.text = parts[0];
                _lastNameController.text = parts[1];
              } else if (parts.length > 2) {
                _firstNameController.text = parts[0];
                _lastNameController.text = parts.last;
                _middleNameController.text = parts
                    .sublist(1, parts.length - 1)
                    .join(' ');
              }
            }

            _studentIdController.text = info['student_number'] ?? '';
            _courseController.text = info['program'] ?? '';
            _specializationController.text = info['specialization'] ?? '';
            if (info['year_level'] != null) {
              _yearLevel = info['year_level'] as int;
            }
            final rawImg = info['img_path'];
            _imgPath = (rawImg is String && rawImg.isNotEmpty) ? rawImg : null;
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
        ToastService.showSuccess(context, 'Profile picture updated!');
      }
    } catch (e) {
      if (mounted) {
        ToastService.showError(
          context,
          e.toString().replaceFirst('Exception: ', ''),
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
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
              style: TextStyle(color: AppColors.maroon, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Change Password ───────────────────────────────────────────────────────
  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool isLoading = false;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Change Password',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildEditField(
                    controller: currentPasswordController,
                    hint: 'Current Password',
                  ),
                  _buildEditField(
                    controller: newPasswordController,
                    hint: 'New Password',
                  ),
                  _buildEditField(
                    controller: confirmPasswordController,
                    hint: 'Confirm New Password',
                  ),
                ],
              ),
            ),
            actions: [
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: AppColors.maroon,
                      strokeWidth: 2,
                    ),
                  ),
                )
              else ...[
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (newPasswordController.text !=
                        confirmPasswordController.text) {
                      ToastService.showError(
                        context,
                        'New passwords do not match.',
                      );
                      return;
                    }
                    if (newPasswordController.text.length < 8) {
                      ToastService.showError(
                        context,
                        'Password must be at least 8 characters.',
                      );
                      return;
                    }

                    setDialogState(() => isLoading = true);
                    try {
                      await ProfileApi.changePassword(
                        currentPassword: currentPasswordController.text,
                        newPassword: newPasswordController.text,
                        confirmPassword: confirmPasswordController.text,
                      );
                      if (context.mounted) {
                        Navigator.of(dialogContext).pop();
                        ToastService.showSuccess(
                          context,
                          'Password changed successfully!',
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ToastService.showError(
                          context,
                          e.toString().replaceFirst('Exception: ', ''),
                        );
                        setDialogState(() => isLoading = false);
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.maroon,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Change',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  void _showComingSoon() {
    ToastService.showInfo(context, 'Feature coming soon!');
  }

  // ─── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.maroon))
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
                            label: 'Change Password',
                            onTap: _showChangePasswordDialog,
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
                                color: AppColors.textSecondary,
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
                            iconColor: AppColors.maroon,
                            labelColor: AppColors.maroon,
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
      color: AppColors.surfaceWhite,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Profile',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
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
              color: AppColors.textPrimary,
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
          colors: [AppColors.maroonLight, AppColors.maroon],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.maroon.withValues(alpha: 0.28),
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
                      _fullName.isEmpty ? 'Student' : _fullName,
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
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildEditField(controller: _firstNameController, hint: 'First Name'),
          _buildEditField(
            controller: _middleNameController,
            hint: 'Middle Name (Optional)',
          ),
          _buildEditField(controller: _lastNameController, hint: 'Last Name'),
          _buildEditField(
            controller: _studentIdController,
            hint: 'Student ID',
            readOnly: true,
          ),
          // Course / Program Dropdown
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              initialValue: kBackendPrograms.containsKey(_courseController.text)
                  ? _courseController.text
                  : null,
              decoration: InputDecoration(
                labelText: 'Course / Program',
                labelStyle: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
                filled: true,
                fillColor: AppColors.surfaceWhite,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.maroon, width: 1.5),
                ),
              ),
              items: kBackendPrograms.entries.map((e) {
                return DropdownMenuItem<String>(
                  value: e.key,
                  child: Text(
                    e.value,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _courseController.text = newValue;
                    _specializationController.text =
                        ''; // Reset on program change
                  });
                }
              },
            ),
          ),
          // Specialization Dropdown
          if (kBackendSpecializations.containsKey(_courseController.text))
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue:
                    kBackendSpecializations[_courseController.text]!.contains(
                      _specializationController.text,
                    )
                    ? _specializationController.text
                    : null,
                decoration: InputDecoration(
                  labelText: 'Specialization',
                  labelStyle: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceWhite,
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
                    borderSide: const BorderSide(color: AppColors.maroon, width: 1.5),
                  ),
                ),
                items: kBackendSpecializations[_courseController.text]!.map((
                  String value,
                ) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _specializationController.text = newValue;
                    });
                  }
                },
              ),
            ),
          // Year Level Dropdown
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: DropdownButtonFormField<int>(
              isExpanded: true,
              initialValue: _yearLevel,
              decoration: InputDecoration(
                labelText: 'Year Level',
                labelStyle: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
                filled: true,
                fillColor: AppColors.surfaceWhite,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.maroon, width: 1.5),
                ),
              ),
              items: [1, 2, 3, 4].map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(
                    value.toString(),
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (int? newValue) {
                if (newValue != null) {
                  setState(() {
                    _yearLevel = newValue;
                  });
                }
              },
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _isEditMode = false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.borderLight),
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
                  onPressed: () async {
                    setState(() => _isLoading = true);
                    try {
                      await ProfileApi.updateProfile(
                        firstName: _firstNameController.text.trim(),
                        middleName: _middleNameController.text.trim(),
                        lastName: _lastNameController.text.trim(),
                        program: _courseController.text,
                        specialization: _specializationController.text,
                        yearLevel: _yearLevel,
                      );
                      await _fetchProfile();
                      if (!mounted) return;
                      setState(() => _isEditMode = false);
                      ToastService.showSuccess(
                        context,
                        'Profile updated successfully!',
                      );
                    } catch (e) {
                      if (!mounted) return;
                      ToastService.showError(
                        context,
                        e.toString().replaceFirst('Exception: ', ''),
                      );
                      setState(() => _isLoading = false);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.maroon,
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
        style: TextStyle(
          fontSize: 13,
          color: readOnly ? AppColors.textSecondary : AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: hint,
          labelStyle: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          filled: true,
          fillColor: readOnly ? AppColors.surfaceGrey : AppColors.surfaceWhite,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.borderLight),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.borderLight),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.maroon, width: 1.5),
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
          color: labelColor ?? AppColors.textPrimary,
        ),
      ),
      trailing:
          trailing ??
          (showArrow
              ? const Icon(Icons.chevron_right, color: AppColors.textLight, size: 20)
              : null),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }
}
