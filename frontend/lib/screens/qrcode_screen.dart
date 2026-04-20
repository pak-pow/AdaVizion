import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/api/api_config.dart';
import '../services/api/landmark_api.dart';

/// The main entry point for the QR code scanning screen.
/// This screen uses the `mobile_scanner` package to access the device's camera and scan for QR codes.
class QRCodeScreen extends StatefulWidget {
  const QRCodeScreen({super.key});

  @override
  State<QRCodeScreen> createState() => _QRCodeScreenState();
}

class _QRCodeScreenState extends State<QRCodeScreen> {
  // this allows us to control the camera and listen for QR code scans
  final MobileScannerController _cameraController = MobileScannerController();
  final double _scanAreaSize = 250.0;
  bool _isScanning = true;

  // ─── BRANDING COLORS ────────────────────────────────────────────────────────
  // Static constants keep our color palette consistent and easy to update
  static const _maroon = Color(0xFF7A1D1D);
  static const _maroonDark = Color(0xFF5D1414);
  static const _gradientTop = Color(0xFFB72424);
  static const _gradientBottom = Color(0xFF5D1414);

  // ─── Camera Controller ────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    /// Calculates the center of the screen to position the scanning frame correctly.
    /// This ensures that the scanning frame is always centered regardless of device size or orientation.
    final scanWindow = Rect.fromCenter(
      center: Offset(
        MediaQuery.of(context).size.width / 2,
        MediaQuery.of(context).size.height / 2,
      ),
      width: _scanAreaSize,
      height: _scanAreaSize,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Image.asset("assets/images/nav_logo.png", height: 48),
        elevation: 1,
        // Removed actions from here to move them to the footer
      ),
      body: Stack(
        children: [
          // 1. THE CAMERA LAYER
          MobileScanner(
            controller: _cameraController,
            fit: BoxFit.cover,
            scanWindow: scanWindow,
            onDetect: (capture) {
              if (_isScanning) {
                final barcode = capture.barcodes.first;
                final value = barcode.rawValue;
                if (value != null && value.isNotEmpty) {
                  _handleScan(value);
                }
              }
            },
          ),

          // 2. THE SCANNING FRAME (Center)
          Align(
            alignment: Alignment.center,
            child: Container(
              height: _scanAreaSize,
              width: _scanAreaSize,
              decoration: BoxDecoration(
                border: Border.all(color: _maroon, width: 4),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),

          // 3. THE FOOTER (Buttons and Instructions)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              decoration: BoxDecoration(
                // Adding a slight gradient/fade behind buttons for readability
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Center the QR code within the frame",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // --- FLASHLIGHT BUTTON ---
                      _buildControlButton(
                        onPressed: () => _cameraController.toggleTorch(),
                        icon: ValueListenableBuilder(
                          valueListenable: _cameraController,
                          builder: (context, state, child) {
                            switch (state.torchState) {
                              case TorchState.on:
                                return const Icon(
                                  Icons.flash_on,
                                  color: Colors.yellow,
                                );
                              case TorchState.auto:
                                return const Icon(
                                  Icons.flash_auto,
                                  color: Colors.blue,
                                );
                              default:
                                return const Icon(
                                  Icons.flash_off,
                                  color: Colors.white,
                                );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── SCAN HANDLING ────────────────────────────────────────────────────────
  Future<void> _handleScan(String qrCode) async {
    setState(() => _isScanning = false);
    _cameraController.stop();

    try {
      final checklist = await LandmarkApi.getChecklist();

      // TODO: Redo when QR code format is finalized
      final int? scannedId = int.tryParse(qrCode);

      if (scannedId == null) {
        _showInvalidQrDialog();
        return;
      }

      final match = checklist.firstWhere(
        (l) => l['landmark_id'] == scannedId,
        orElse: () => null,
      );

      if (match == null) {
        _showInvalidQrDialog();
        return;
      }

      final result = await LandmarkApi.visitLandmark(scannedId, qrCode);

      if (!mounted) return;
      _showSuccessDialog(result);
    } catch (e) {
      if (!mounted) return;

      final message = e.toString();
      if (message.contains('already visited')) {
        _showAlreadyVisitedDialog();
      } else if (message.contains('invalid landmark')) {
        _showInvalidQrDialog();
      } else {
        _showErrorDialog();
      }
    }
  }

  // ─── HELPER METHODS ────────────────────────────────────────────────────────

  /// Clean up the camera controller when the widget is disposed to free up resources.
  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  /// Resets the scanner state to allow for another scan after a QR code has been processed.
  void _resetScanner() {
    _cameraController.start();
    setState(() => _isScanning = true);
  }

  void _showSuccessDialog(Map<String, dynamic> result) {
    final landmark = result['landmark'];
    final progress = result['progress'];
    final xpEarned = progress['xp']['earned'];
    final didLevelUp = progress['level']['did_level_up'];
    final achievements = result['new_achievements'] as List;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Landmark Detected!", textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              landmark['name'],
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              "Fun Fact: ${landmark['fun_fact']}",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              "$xpEarned XP",
              style: TextStyle(color: _maroon, fontWeight: FontWeight.bold),
            ),
            if (didLevelUp)
              const Text("Level Up!", textAlign: TextAlign.center),
            if (achievements.isNotEmpty)
              Text("${achievements.length} new achievement(s)!"),
          ],
        ),

        // MODAL BUTTONS
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(
                context,
              ); // Go back to the previous screen (e.g., dashboard)
            },
            style: TextButton.styleFrom(foregroundColor: _maroon),
            child: const Text("Close"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to landmark details screen
              // Navigator.pushNamed(context, '/landmark_details', arguments: landmark['id']);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _maroonDark,
              foregroundColor: Colors.white,
            ),
            child: const Text("View Landmark"),
          ),
        ],
      ),
    ).then((_) => _resetScanner());
  }

  /// Shows an error dialog with a custom message, used for unexpected errors during the scanning process.
  void _showInvalidQrDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("Invalid QR Code:", textAlign: TextAlign.center),
        content: const Text(
          "This doesn't seem to be a campus landmark. Try scanning again.",
          textAlign: TextAlign.center,
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _resetScanner();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _maroonDark,
              foregroundColor: Colors.white,
            ),
            child: const Text("Scan Again"),
          ),
        ],
      ),
    );
  }

  /// Shows a dialog indicating that the landmark has already been visited, preventing duplicate scans.
  void _showAlreadyVisitedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text(
          "Landmark Already Visited",
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: _maroon),
            child: const Text("Close"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _resetScanner();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _maroonDark,
              foregroundColor: Colors.white,
            ),
            child: const Text("Scan Another"),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Something went wrong", textAlign: TextAlign.center),
        content: const Text(
          "Couldn't connect to the server. Check your connection and try again.",
          textAlign: TextAlign.center,
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _resetScanner();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _maroonDark,
              foregroundColor: Colors.white,
            ),
            child: const Text("Try Again"),
          ),
        ],
      ),
    );
  }

  // Helper method to keep the button code clean
  Widget _buildControlButton({
    required Widget icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _maroon.withValues(alpha: 0.8),
        shape: BoxShape.circle,
      ),
      child: IconButton(iconSize: 30, onPressed: onPressed, icon: icon),
    );
  }
}
