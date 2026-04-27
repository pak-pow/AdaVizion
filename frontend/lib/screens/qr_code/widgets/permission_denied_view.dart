// ─── PERMISSION DENIED UI ─────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../qr_code_constants.dart';

/// Full-screen widget displayed when camera permission has been denied.
///
/// Shows an explanatory message and a "Try Again" button. The button
/// callback should re-initialise the scanner controller and re-trigger
/// the OS / browser permission prompt.

class PermissionDeniedView extends StatelessWidget {
  /// Creates a [PermissionDeniedView].
  ///
  /// - [onRetry] is invoked when the user taps the "Try Again" button.
  const PermissionDeniedView({super.key, required this.onRetry});

  /// Callback executed when the user taps "Try Again".
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.no_photography_outlined,
              color: Colors.white54,
              size: 72,
            ),
            const SizedBox(height: 24),
            const Text(
              "Camera Access Required",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "EUventure needs camera access to scan QR codes at campus landmarks. "
              "Please enable it in your device/browser settings.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, height: 1.5),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text("Try Again"),
              style: ElevatedButton.styleFrom(
                backgroundColor: QRCodeConstants.maroonDark,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
