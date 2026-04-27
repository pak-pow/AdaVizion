import 'package:flutter/material.dart';

// ============================================================================
// SUCCESS LAYOUT VIEW
//
// Extracted from login_screen.dart _buildSuccessLayout() (lines 500–597).
// Shown after successful registration. Receives a single callback to navigate
// back to login.
// ============================================================================

/// Confirmation card shown after a successful student registration.
///
/// Extracted from `_AuthScreenState._buildSuccessLayout()`.
class SuccessLayoutView extends StatelessWidget {
  const SuccessLayoutView({
    super.key,
    required this.onGoToLogin,
  });

  /// Called when the user taps "Go to Login", allowing the parent shell
  /// to switch auth state back to [AuthState.login].
  final VoidCallback onGoToLogin;

  static const _maroon = Color(0xFF7A1D1D);
  static const _maroonDark = Color(0xFF5D1414);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 80),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            // LAYER 1 (BACK): Confirmation Card
            Container(
              margin: const EdgeInsets.only(
                top: 60,
                left: 32,
                right: 32,
                bottom: 40,
              ),
              padding: const EdgeInsets.fromLTRB(24, 70, 24, 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 15,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Account Created\nSuccessfully!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: _maroon,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'You can scan, learn, and enjoy\nwith EUventure',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _maroon,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),

                  OutlinedButton(
                    onPressed: onGoToLogin,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _maroonDark,
                      side:
                          const BorderSide(color: _maroonDark, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      minimumSize: const Size(0, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Go to Login',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // LAYER 2 (FRONT): Small Mascot
            Positioned(
              top: 0,
              child: Image.asset(
                'assets/images/logo.png',
                height: 120,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
