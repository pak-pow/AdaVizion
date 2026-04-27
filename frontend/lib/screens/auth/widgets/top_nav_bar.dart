import 'package:flutter/material.dart';
import '../auth_enums.dart';

// ============================================================================
// AUTH TOP NAVIGATION BAR
//
// Extracted from login_screen.dart _buildTopNav() + _navTextItem().
// Receives current navigation state and callbacks — owns no state itself.
// ============================================================================

/// The persistent navigation bar displayed at the top of the auth screens.
///
/// Extracted from `_AuthScreenState._buildTopNav()` and `_navTextItem()`.
class AuthTopNavBar extends StatelessWidget {
  const AuthTopNavBar({
    super.key,
    required this.currentView,
    required this.authState,
    required this.onNavigate,
  });

  final AppView currentView;
  final AuthState authState;

  /// Unified navigation callback.
  ///
  /// Called with the target [AppView] and an optional [AuthState] when the
  /// destination is the auth sub-view (e.g. login vs signup).
  final void Function(AppView view, {AuthState? specificAuth}) onNavigate;

  // ─── BRANDING COLORS ──────────────────────────────────────────────────────
  static const _maroon = Color(0xFF7A1D1D);
  static const _maroonDark = Color(0xFF5D1414);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmall = screenWidth < 500;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      // Creates the grey-to-white-to-grey horizontal gradient matching the Figma design
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFFEBEBEB),
            Colors.white,
            Colors.white,
            Color(0xFFEBEBEB),
          ],
          stops: [0.0, 0.31, 0.59, 1.0],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Nav Bar Brand Logo
          Image.asset('assets/images/nav_logo.png', height: isSmall ? 40 : 48),

          const SizedBox(width: 8),

          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _navTextItem('Homepage', AppView.home),
                SizedBox(width: isSmall ? 12 : 24),
                _navTextItem('About', AppView.about),
                SizedBox(width: isSmall ? 12 : 24),
                _navTextItem(
                  'Sign in',
                  AppView.auth,
                  specificAuth: AuthState.login,
                ),
                SizedBox(width: isSmall ? 16 : 32),

                // Highlighted "Sign up" Call-to-Action Button
                ElevatedButton(
                  onPressed: () =>
                      onNavigate(AppView.auth, specificAuth: AuthState.signup),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _maroonDark,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmall ? 16 : 36,
                      vertical: 0,
                    ),
                    minimumSize: Size(0, isSmall ? 32 : 42),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Sign up',
                    style: TextStyle(
                      fontSize: isSmall ? 11 : 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Helper to build interactive text links in the top navigation.
  /// Handles active state styling (red underline and bolder font).
  Widget _navTextItem(
    String text,
    AppView targetView, {
    AuthState? specificAuth,
  }) {
    // Determine if this specific link is the currently active view
    bool isActive = currentView == targetView;
    if (specificAuth != null && currentView == AppView.auth) {
      isActive = authState == specificAuth;
    }

    return GestureDetector(
      onTap: () => onNavigate(targetView, specificAuth: specificAuth),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        decoration: BoxDecoration(
          // Applies the maroon underline only if active
          border: isActive
              ? const Border(bottom: BorderSide(color: _maroon, width: 2.0))
              : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w900 : FontWeight.bold,
            color: isActive ? _maroon : Colors.black87,
          ),
        ),
      ),
    );
  }
}
