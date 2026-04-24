import 'package:flutter/material.dart';
import '../../../services/api/api_config.dart';
import '../../../services/api/profile_api.dart';
import '../../login_screen.dart';

// ============================================================================
// SETTINGS VIEW
//
// Gizmo-style Profile & Settings screen rendered at tab index 3.
//
// Sections:
//   Header  — "Profile" title + settings gear icon
//   Banner  — Avatar, full name, program (fetched from ProfileApi)
//   Account — Edit Profile, Notifications, Privacy & Security
//   App     — App Version (v1.0.0)
//   Session — Log Out (maroon, with confirmation dialog)
//
// onEditProfile: VoidCallback supplied by DashboardScreen that switches
// _selectedIndex back to 0 (Home tab). The pencil edit button in the Home
// profile card is the actual edit entry point.
// ============================================================================

class SettingsView extends StatefulWidget {
  const SettingsView({super.key, required this.onEditProfile});

  /// Called when the user taps "Edit Profile". DashboardScreen uses this
  /// to navigate to the Home tab (index 0) where the edit pencil lives.
  final VoidCallback onEditProfile;

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  // ── Brand colours ─────────────────────────────────────────────────────────
  static const _maroon = Color(0xFF7A1D1D);

  // ── Profile data ──────────────────────────────────────────────────────────
  bool _isLoading = true;
  String _name = '';
  String _program = '';
  String? _imgPath;

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
            _name = '$firstName $lastName'.trim();
            _program = info['program'] ?? '';
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

  // ── Logout ────────────────────────────────────────────────────────────────
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

  // ── Build ─────────────────────────────────────────────────────────────────
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
                        // Profile banner
                        _buildProfileBanner(),
                        const SizedBox(height: 28),

                        // ── Account section ──────────────────────────────
                        _buildSectionLabel('Account'),
                        _buildSettingsGroup([
                          _buildTile(
                            icon: Icons.edit_outlined,
                            label: 'Edit Profile',
                            onTap: widget.onEditProfile,
                          ),
                          _buildTile(
                            icon: Icons.notifications_outlined,
                            label: 'Notifications',
                            onTap: () {},
                          ),
                          _buildTile(
                            icon: Icons.lock_outline,
                            label: 'Privacy & Security',
                            onTap: () {},
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

  // ── Header ────────────────────────────────────────────────────────────────
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

  // ── Profile banner ────────────────────────────────────────────────────────
  Widget _buildProfileBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFEEEEEE),
              shape: BoxShape.circle,
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
                    size: 32,
                    color: Colors.grey,
                  )
                : null,
          ),
          const SizedBox(width: 16),

          // Name + program
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _name.isEmpty ? 'Student' : _name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                if (_program.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    _program,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Section helpers ───────────────────────────────────────────────────────
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

  /// Wraps a list of tile widgets in a single rounded white card,
  /// with a hairline divider between adjacent tiles.
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
