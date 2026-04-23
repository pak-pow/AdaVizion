import 'package:flutter/foundation.dart' show kIsWeb;
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
  // ─── FIELDS ───────────────────────────────────────────────────────────────
  Key _scannerKey = UniqueKey();
  late MobileScannerController _cameraController;
  final double _scanAreaSize = 250.0;
  bool? _cameraPermissionGranted;
  bool _isScanning = true;
  bool _isLoading = false;

  // ─── BRANDING COLORS ──────────────────────────────────────────────────────
  static const _maroon = Color(0xFF7A1D1D);
  static const _maroonDark = Color(0xFF5D1414);
  static const _headerGrey = Color(0xFFF5F5F5);

  // ─── LIFECYCLE ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _initController();
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  void _initController() {
    _cameraController = MobileScannerController();
    _cameraController.addListener(_onControllerStateChanged);
  }

  void _disposeController() {
    _cameraController.removeListener(_onControllerStateChanged);
    _cameraController.dispose();
  }

  /// Called whenever the MobileScannerController emits a new state.
  ///
  /// Note: on web, permission denial may not reliably surface as state.error
  /// in the listener — it can arrive as an exception thrown inside the
  /// MobileScanner widget's build cycle instead. That case is handled by
  /// [_onScannerError] via the widget's errorBuilder parameter.
  void _onControllerStateChanged() {
    final state = _cameraController.value;
    if (!mounted) return;

    if (state.isInitialized) {
      setState(() => _cameraPermissionGranted = true);
    } else if (state.error != null && _cameraPermissionGranted != true) {
      setState(() => _cameraPermissionGranted = false);
    }
  }

  /// Called by MobileScanner's errorBuilder when the widget itself encounters
  /// an error — most commonly a NotAllowedError (permission denied) on web.
  Widget _onScannerError(BuildContext context, MobileScannerException error) {
    if (_cameraPermissionGranted != false) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _cameraPermissionGranted != false) {
          setState(() => _cameraPermissionGranted = false);
        }
      });
    }
    return const SizedBox.expand();
  }

  // ─── BUILD ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: _headerGrey,
        centerTitle: true,
        title: Image.asset("assets/images/nav_logo.png", height: 48),
        elevation: 1,
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    const appBarHeight = kToolbarHeight;

    final scanWindow = kIsWeb
        ? null
        : Rect.fromCenter(
            center: Offset(
              screenSize.width / 2,
              appBarHeight + (screenSize.height - appBarHeight) / 2,
            ),
            width: _scanAreaSize,
            height: _scanAreaSize,
          );

    return Stack(
      fit: StackFit.expand,
      children: [
        // ── 1. CAMERA LAYER — always mounted ────────────────────────────────
        MobileScanner(
          key: _scannerKey,
          controller: _cameraController,
          fit: BoxFit.cover,
          scanWindow: scanWindow,
          errorBuilder: _onScannerError,
          onDetect: (capture) {
            if (!_isScanning || _cameraPermissionGranted != true) return;
            final value = capture.barcodes.firstOrNull?.rawValue;
            if (value != null && value.isNotEmpty) {
              _handleScan(value);
            }
          },
        ),

        // ── 2. SCAN OVERLAY — visual guide, shown only when camera is active
        if (_cameraPermissionGranted == true)
          CustomPaint(
            painter: _ScanOverlayPainter(
              scanAreaSize: _scanAreaSize,
              borderColor: _maroon,
            ),
          ),

        // ── 3. PERMISSION PENDING — spinner while browser popup is open ─────
        if (_cameraPermissionGranted == null)
          const ColoredBox(
            color: Colors.black,
            child: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),

        // ── 4. PERMISSION DENIED — covers camera layer entirely ─────────────
        if (_cameraPermissionGranted == false)
          ColoredBox(color: Colors.black, child: _buildPermissionDeniedUI()),

        // ── 5. FOOTER — torch button, only when camera is active ────────────
        if (_cameraPermissionGranted == true)
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

        // ── 6. LOADING OVERLAY ───────────────────────────────────────────────
        if (_isLoading)
          ColoredBox(
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

  // ─── PERMISSION DENIED UI ─────────────────────────────────────────────────

  Widget _buildPermissionDeniedUI() {
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

  // ─── SCAN HANDLING ────────────────────────────────────────────────────────

  Future<void> _handleScan(String qrCode) async {
    if (!mounted) return;

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
      _onScanError(e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onScanError(Object e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains("already visited")) {
      return _showAlreadyVisitedDialog();
    }
    if (msg.contains("not found") || msg.contains("invalid")) {
      return _showInvalidQrDialog();
    }
    _showErrorDialog();
  }

  /// Resets state to null (spinner) then restart the controller.
  /// On web, restarting re-calls getUserMedia which re-triggers the browser popup.
  void _retryPermission() {
    _disposeController();
    _initController();
    setState(() {
      _cameraPermissionGranted = null;
      _scannerKey = UniqueKey();
    });
  }

  void _resetScanner() {
    _cameraController.start();
    setState(() => _isScanning = true);
  }

  // ─── DIALOGS ───────────────────────────────────────────────────────

  /// Shows a dialog with a title, optional content, and action buttons.
  ///
  /// Parameters:
  ///   [title] — The main heading of the dialog.
  ///   [content] — Optional widget to display below the title (e.g. error message or fun fact).
  ///   [actions] — A list of buttons to show at the bottom of the dialog.
  ///
  /// Note: For the "Landmark Unlocked!" dialog, the [result] from the API call is used
  /// to populate the content and rewards shown in the dialog. For error dialogs,
  Future<T?> _showScanDialog<T>({
    required String title,
    Widget? content,
    required List<Widget> actions,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: EdgeInsets.zero,
        title: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: _maroonDark,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        content: content,
        actions: actions,
      ),
    );
  }

  /// Dialog button builder to reduce boilerplate in dialog definitions. Can create either
  /// a filled ElevatedButton or a TextButton based on [isText].
  ///
  /// Parameters:
  ///  [label] — The text to display on the button.
  ///  [onPressed] — The callback to execute when the button is pressed.
  ///  [isText] — If true, creates a TextButton; otherwise, creates an ElevatedButton with maroon styling.
  ///
  Widget _dialogButton({
    required String label,
    required VoidCallback onPressed,
    bool isText = false,
  }) {
    if (isText) {
      return TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(foregroundColor: _maroonDark),
        child: Text(label),
      );
    }
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: _maroonDark,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(label),
    );
  }

  /// Closes the currently open dialog and then executes the provided [action].
  /// This is used to ensure that when a dialog button is pressed, the dialog is dismissed before performing any state changes or navigation.
  ///
  /// Parameters:
  ///   [action] — The callback function to execute after the dialog is closed.
  void _closeDialogAnd(VoidCallback action) {
    Navigator.pop(context);
    action();
  }

  /// Shows the "Landmark Unlocked!" dialog after a successful scan, displaying the landmark's name,
  /// fun fact, XP earned, level-up status, and any new achievements.
  /// The dialog includes buttons to either close the dialog or navigate to the landmark details page.
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
                  fontSize: 18,
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
                            fontSize: 14,
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
        actions: [
          _dialogButton(
            label: "Close",
            isText: true,
            onPressed: () => _closeDialogAnd(_resetScanner),
          ),
          _dialogButton(
            label: "View Landmark",
            onPressed: () =>
                _closeDialogAnd(() => _navigateToLandmarkDetails(landmarkId)),
          ),
        ],
      ),
    ).then((_) => _resetScanner());
  }

  /// Shows an error dialog when the scanned QR code is not recognized as a valid landmark code.
  /// This is triggered when the backend returns a 403 error indicating an invalid QR code, which means
  /// the scanned code does not match any landmark's `qr_string` in the database, or the QR code is malformed.
  void _showInvalidQrDialog() {
    _showScanDialog(
      title: "Invalid QR Code",
      content: const Text(
        "This doesn't seem to be a valid landmark QR code. Please try scanning again.",
        textAlign: TextAlign.center,
      ),
      actions: [
        _dialogButton(
          label: "Scan Again",
          onPressed: () => _closeDialogAnd(_resetScanner),
        ),
      ],
    );
  }

  void _showAlreadyVisitedDialog() {
    _showScanDialog(
      title: "Landmark Already Visited!",
      content: const SizedBox(height: 4),
      actions: [
        _dialogButton(
          label: "Close",
          isText: true,
          onPressed: () => _closeDialogAnd(() => Navigator.pop(context)),
        ),
        _dialogButton(
          label: "Scan Another",
          onPressed: () => _closeDialogAnd(_resetScanner),
        ),
      ],
    );
  }

  void _showErrorDialog() {
    _showScanDialog(
      title: "Something Went Wrong!",
      content: const Text(
        "Couldn't connect to the server. Check your connection and try again.",
        textAlign: TextAlign.center,
      ),
      actions: [
        _dialogButton(
          label: "Try Again",
          onPressed: () => _closeDialogAnd(_resetScanner),
        ),
      ],
    );
  }

  // ─── WIDGET HELPERS ─────────────────────────────────────────────────────────

  /// Navigates to the landmark details screen for the given [landmarkId].
  /// This is called after a successful scan when the user taps "View Landmark" in the success dialog.
  /// TODO: Reroute to the correct details screen once the new details page is implemented.
  void _navigateToLandmarkDetails(int landmarkId) {
    Navigator.pushNamed(context, '/landmark_details', arguments: landmarkId);
  }

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
/// On web this is a visual guide only — mobile_scanner's web implementation
/// does not honour scanWindow, so the full camera frame is always scanned.
/// On native (iOS/Android) this aligns with the scanWindow rect passed to
/// MobileScanner, which restricts actual barcode detection to the box.
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

    final overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(rrect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(overlayPath, overlayPaint);
    canvas.drawRRect(rrect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _ScanOverlayPainter oldDelegate) =>
      oldDelegate.scanAreaSize != scanAreaSize ||
      oldDelegate.borderColor != borderColor;
}
