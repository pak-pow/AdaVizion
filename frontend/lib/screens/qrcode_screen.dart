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
  // ─── STATE VARIABLES ────────────────────────────────────────────────────────
  final double _scanAreaSize = 250.0;
  bool _isScanning = true;
  bool _isLoading = false;

  // ─── CONTROLLERS ────────────────────────────────────────────────────────────
  final MobileScannerController _cameraController = MobileScannerController();

  // ─── PERMISSION STATE ───────────────────────────────────────────────────────
  // null = not yet determined, true = granted, false = denied
  bool? _cameraPermissionGranted;

  // ─── BRANDING COLORS ────────────────────────────────────────────────────────
  // Static constants keep our color palette consistent and easy to update
  static const _maroon = Color(0xFF7A1D1D);
  static const _maroonDark = Color(0xFF5D1414);

  // ─── LIFECYCLE ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _checkCameraPermission();
  }

  /// Checks for camera permission state on startup.
  /// Listens to the controller's value stream so the UI reacts if the user
  /// grants/denies permission while on this screen.
  Future<void> _checkCameraPermission() async {
    _cameraController.addListener(_onControllerStateChanged);

    // Starts the camera | mobile_scanner will automatically request permission
    // Listens to the resulting state to know if it was granted or denied
    await _cameraController.start();
  }

  /// Called whenever the MobileScannerController's emits a new state, which includes permission changes.
  /// Used to react to permission changes without a third-party package.
  void _onControllerStateChanged() {
    final state = _cameraController.value;

    if (!mounted) return;

    // MobileScannerState exposes an error field when camera access fails.
    if (state.error != null) {
      setState(() => _cameraPermissionGranted = false);
    } else if (state.isInitialized) {
      setState(() => _cameraPermissionGranted = true);
    }
  }

  /// Clean up the camera controller when the widget is disposed to free up resources.
  @override
  void dispose() {
    _cameraController.removeListener(_onControllerStateChanged);
    _cameraController.dispose();
    super.dispose();
  }

  // ─── BUILD ──────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Image.asset("assets/images/nav_logo.png", height: 48),
        elevation: 1,
      ),
      body: _buildBody(context),
    );
  }

  /// Switches between camera view and permission-denied fallback.
  Widget _buildBody(BuildContext context) {
    // Show a neutral loading state while we wait for the controller to init.
    if (_cameraPermissionGranted == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_cameraPermissionGranted == false) {
      return _buildPermissionDeniedUI();
    }

    return _buildScannerUI(context);
  }

  // ==========================================
  // PERMISSION DENIED UI
  // ==========================================

  /// Displays a user-friendly message when camera permission is denied, along with instructions and a retry button.
  Widget _buildPermissionDeniedUI() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
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
              "Please enable it in your device settings.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, height: 1.5),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _retryPermission,
              icon: const Icon(Icons.refresh),
              label: const Text("Try Again"),
              style: ElevatedButton.styleFrom(
                backgroundColor: _maroonDark,
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

  /// Restarts the camera controller to trigger the permission request.
  Future<void> _retryPermission() async {
    setState(() => _cameraPermissionGranted = null);

    try {
      await _cameraController.start();
    } catch (e) {
      if (mounted) setState(() => _cameraPermissionGranted = false);
    }
  }

  // ==========================================
  // SCANNER UI
  // ==========================================

  /// Builds the main scanner interface with the camera feed, scanning frame, and control buttons.
  Widget _buildScannerUI(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    /// scanWindow must be in ABSOLUTE PIXEL coordinates relative to the full
    /// screen (not the body). mobile_scanner compares barcode positions against
    /// this rect | if the barcode center falls outside, it is ignored.
    ///
    /// The AppBar is ~56dp tall (kToolbarHeight), so we offset the vertical
    /// center down by half that to align the visible frame drawn below.
    const appBarHeight = kToolbarHeight;
    final scanWindow = Rect.fromCenter(
      center: Offset(
        screenSize.width / 2,
        // Center of the BODY area, converted to full screen coordinates
        appBarHeight + (screenSize.height - appBarHeight) / 2,
      ),
      width: _scanAreaSize,
      height: _scanAreaSize,
    );

    return Stack(
      children: [
        // 1. CAMERA LAYER
        MobileScanner(
          controller: _cameraController,
          fit: BoxFit.cover,
          scanWindow: scanWindow,
          onDetect: (capture) {
            if (!_isScanning) return;
            final value = capture.barcodes.firstOrNull?.rawValue;
            if (value != null && value.isNotEmpty) {
              _handleScan(value);
            }
          },
        ),

        // 2. OVERLAY — darkens everything OUTSIDE the scan frame.
        CustomPaint(
          size: Size(screenSize.width, screenSize.height - appBarHeight),
          painter: _ScanOverlayPainter(
            scanAreaSize: _scanAreaSize,
            borderColor: _maroon,
          ),
        ),

        // 3. FOOTER
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            decoration: BoxDecoration(
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
    );
  }

  // ─── SCAN HANDLING ────────────────────────────────────────────────────────

  /// Called once per scan. Delegated entirely to the backend - no client-side validation
  /// is done on the QR code string, we just try to submit it and react to the response.
  Future<void> _handleScan(String qrCode) async {
    setState(() {
      _isScanning = false;
      _isLoading = true;
    });
    _cameraController.stop();

    try {
      final result = await LandmarkApi.visitLandmark(qrCode);

      if (!mounted) return;
      _showSuccessDialog(result);
    } catch (e) {
      if (!mounted) return;

      final errorMsg = e.toString().toLowerCase();

      if (errorMsg.contains("already visited")) {
        _showAlreadyVisitedDialog();
      } else if (errorMsg.contains("not found") ||
          errorMsg.contains("invalid")) {
        _showInvalidQrDialog();
      } else {
        _showErrorDialog();
      }
    }
  }

  // ─── HELPER METHODS ────────────────────────────────────────────────────────

  /// Resets the scanner state to allow for another scan after a QR code has been processed.
  void _resetScanner() {
    _cameraController.start();
    setState(() => _isScanning = true);
  }

  /// Navigates to the Landmark Details screen for the newly scanned landmark, passing the landmark ID as an argument.
  ///
  /// TODO: Replace the `pushNamed` route string with the actual named route
  ///       constant once LandmarkDetailsScreen is registered in your router.
  void _navigateToLandmarkDetails(int landmarkId) {
    Navigator.pushNamed(
      context,
      '/landmark-details',
      arguments: {'landmarkId': landmarkId},
    );
  }

  /// Shows a success dialog with details about the scanned landmark and rewards earned.
  void _showSuccessDialog(Map<String, dynamic> result) {
    final landmark = result['landmark'];
    final progress = result['progress'];
    final xpEarned = progress['xp']['earned'];
    final didLevelUp = progress['level']['did_level_up'];
    final achievements = result['new_achievements'] as List;
    final landmarkId = landmark['landmark_id'] as int;

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
              _navigateToLandmarkDetails(landmarkId);
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

// ─── SCAN OVERLAY PAINTER ──────────────────────────────────────────────────────

/// Draws a semi-transparent dark overlay over the entire camera preview,
/// then "punches out" a clear rounded-rectangle in the center — the scan zone.
///
/// This gives the user a clear visual target AND prevents the temptation to
/// scan things outside the frame (though actual detection restriction is
/// handled by [MobileScanner.scanWindow]).
class _ScanOverlayPainter extends CustomPainter {
  const _ScanOverlayPainter({
    required this.scanAreaSize,
    required this.borderColor,
  });

  final double scanAreaSize;
  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    final overlayPaint = Paint()..color = Colors.black.withValues(alpha: 0.55);
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final center = Offset(size.width / 2, size.height / 2);
    final scanRect = Rect.fromCenter(
      center: center,
      width: scanAreaSize,
      height: scanAreaSize,
    );
    const radius = Radius.circular(20);
    final rrect = RRect.fromRectAndRadius(scanRect, radius);

    // Draw the dark overlay as a full rect with the scan window cut out
    final overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(rrect)
      ..fillType = PathFillType.evenOdd; // the overlap becomes transparent

    canvas.drawPath(overlayPath, overlayPaint);

    // Draw the maroon border around the scan window
    canvas.drawRRect(rrect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _ScanOverlayPainter oldDelegate) =>
      oldDelegate.scanAreaSize != scanAreaSize ||
      oldDelegate.borderColor != borderColor;
}
