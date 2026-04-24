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
          Image.asset('assets/images/nav_logo.png', height: 48),

          Row(
            children: [
              _navTextItem('Homepage', AppView.home),
              const SizedBox(width: 10),
              _navTextItem('About', AppView.about),
              const SizedBox(width: 10),
              _navTextItem(
                'Sign in',
                AppView.auth,
                specificAuth: AuthState.login,
              ),
              const SizedBox(width: 12),

              // Highlighted "Sign up" Call-to-Action Button
              ElevatedButton(
                onPressed: () =>
                    onNavigate(AppView.auth, specificAuth: AuthState.signup),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _maroonDark,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 0,
                  ),
                  minimumSize: const Size(0, 36),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Sign up',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
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
