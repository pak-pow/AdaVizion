import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
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
  bool _isLoading = false;

  // ─── BRANDING COLORS ────────────────────────────────────────────────────────
  // Static constants keep our color palette consistent and easy to update
  static const _maroon = Color(0xFF7A1D1D);
  static const _maroonDark = Color(0xFF5D1414);

  // ─── Camera Controller ────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    /// Calculates the center of the screen to position the scanning frame correctly.
    /// This ensures that the scanning frame is always centered regardless of device size or orientation.
    /// TODO: FIX BUG WHERE STILL SCANS OUTSIDE OF FRAME, MAYBE NEEDS TO BE A BIT BIGGER OR ALLOW SOME MARGIN OF ERROR
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

          // 4. LOADING OVERLAY
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.6),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      "Scanning Landmark...",
                      style: TextStyle(color: Colors.white, fontSize: 16),
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
    setState(() {
      _isScanning = false;
      _isLoading = true;
    });
    _cameraController.stop();

    try {
      final checklist = await LandmarkApi.getChecklist();

      // TODO: ASK BACKEND ABOUT THIS
      // This tries to submit the QR against each landmark until one accepts it.
      // This might be temporary and is not ideal, need to ask neil,
      // if its possible to have a dedicated endpoint that accepts the raw QR code and returns the matched landmark or an error if invalid.
      Map<String, dynamic>? result;

      for (final landmark in checklist) {
        try {
          final id = landmark['landmark_id'] as int;
          result = await LandmarkApi.visitLandmark(id, qrCode);
          break; // If successful, exit the loop
        } catch (e) {
          final msg = e.toString();
          if (msg.contains("already visited")) {
            _showAlreadyVisitedDialog();
            return;
          }
          // catches 403 errors from wrong landmarks and tries again
          continue;
        }
      }

      if (!mounted) return;

      if (result == null) {
        _showInvalidQrDialog();
        return;
      }

      _showSuccessDialog(result);
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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

  /// Shows a success dialog with details about the scanned landmark and rewards earned.
  void _showSuccessDialog(Map<String, dynamic> result) {
    final landmark = result['landmark'];
    final progress = result['progress'];
    final xpEarned = progress['xp']['earned'];
    final didLevelUp = progress['level']['did_level_up'];
    final achievements = result['new_achievements'] as List;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: const EdgeInsets.all(0),
        title: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: _maroonDark,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: const Text(
            "Landmark Unlocked!",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                landmark['name'].toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: _maroon,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _maroon.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          size: 18,
                          color: Colors.red,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "FUN FACT",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      landmark['fun_fact'].toString(),
                      textAlign: TextAlign.justify,
                      style: const TextStyle(fontSize: 14, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildRewardBadge(Icons.bolt, "$xpEarned XP", Colors.red),
                  if (didLevelUp)
                    _buildRewardBadge(
                      Icons.trending_up,
                      "Level Up!",
                      Colors.green,
                    ),
                ],
              ),

              if (achievements.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.emoji_events_outlined,
                      color: _maroonDark,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "${achievements.length} new achievement(s)!",
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        // MODAL BUTTONS
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: _maroonDark),
            child: const Text("Close"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to landmark details screen
              // Navigator.pushNamed(context, '/landmark_details', arguments: landmark['id']);
              // For now, just reset the scanner to encourage exploring more landmarks
              _resetScanner();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _maroonDark,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: const EdgeInsets.all(0),
        title: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: _maroonDark,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: const Text(
            "Invalid QR Code!",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),

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
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: const EdgeInsets.all(0),
        title: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: _maroonDark,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: const Text(
            "Landmark Already Visited!",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        content: const SizedBox(height: 4),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: _maroonDark),
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
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("Scan Another"),
          ),
        ],
      ),
    );
  }

  /// Shows an error dialog with a custom message, used for unexpected errors during the scanning process.
  void _showErrorDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: const EdgeInsets.all(0),
        title: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: _maroonDark,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: const Text(
            "Something Went Wrong!",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
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
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("Try Again"),
          ),
        ],
      ),
    );
  }

  /// Helper method to keep the torch button code clean
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

  /// Helper method to build a reward badge widget, used in the success dialog to display XP earned and achievements unlocked.
  /// TEMPORARY UNTIL ACTUAL BADGE DESIGNS ARE READY
  Widget _buildRewardBadge(IconData icon, String text, Color color) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }
}
