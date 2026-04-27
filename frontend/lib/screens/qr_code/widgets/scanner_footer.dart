// ─── SCANNER FOOTER ─────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:adavizion/theme/app_colors.dart';

/// Bottom footer shown while the camera is active.
///
/// Displays a "centre the QR code" instruction and a torch-toggle button
/// that reflects the current [TorchState] via a [ValueListenableBuilder].

class ScannerFooter extends StatelessWidget {
  /// Creates a [ScannerFooter].
  ///
  /// - [controller] is the active [MobileScannerController] whose torch state
  /// is observed to update the icon colour and symbol reactively.
  const ScannerFooter({super.key, required this.controller});

  /// The active camera controller; used to toggle and read torch state.
  final MobileScannerController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black.withValues(alpha: 0.7), Colors.transparent],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Center the QR code within the frame",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ControlButton(
                onPressed: controller.toggleTorch,
                icon: ValueListenableBuilder(
                  valueListenable: controller,
                  builder: (context, state, _) => _torchIcon(state.torchState),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Returns the appropriate [Icon] for the given [TorchState].
  static Icon _torchIcon(TorchState state) {
    return switch (state) {
      TorchState.on => const Icon(Icons.flash_on, color: Colors.yellow),
      TorchState.auto => const Icon(Icons.flash_auto, color: Colors.blue),
      _ => const Icon(Icons.flash_off, color: Colors.white),
    };
  }
}

/// A circular icon button styled with the app's maroon brand colour.
///
/// Used internally by [ScannerFooter] and can be reused anywhere a
/// circular control button is needed on the scanner screen.
class _ControlButton extends StatelessWidget {
  const _ControlButton({required this.icon, required this.onPressed});

  /// The icon widget to display inside the button.
  final Widget icon;

  /// Called when the button is tapped.
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.maroon.withValues(alpha: 0.8),
        shape: BoxShape.circle,
      ),
      child: IconButton(iconSize: 30, onPressed: onPressed, icon: icon),
    );
  }
}
