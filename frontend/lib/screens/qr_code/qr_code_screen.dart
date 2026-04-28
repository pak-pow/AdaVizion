import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/api/landmark_api.dart';
import '../landmarks/models/landmark_model.dart';
import '../landmarks/views/landmark_detail_view.dart';
import '../dashboard_screen.dart';

import 'package:adavizion/theme/app_colors.dart';
import 'utils/scan_error_handler.dart';
import 'widgets/permission_denied_view.dart';
import 'widgets/scan_dialogs.dart';
import 'widgets/scan_overlay_painter.dart';
import 'widgets/scanner_footer.dart';

/// The main QR-code scanning screen.
///
/// Hosts the [MobileScanner] camera widget and orchestrates:
/// * Camera lifecycle (init, dispose, retry).
/// * Permission-state tracking with graceful fallback UI.
/// * One-time safety-reminder dialog (per student account).
/// * Forwarding successful / failed scans to the appropriate feedback dialog.
///
/// Sub-concerns are delegated to focused helpers:
/// * **[ScanDialogsMixin]** — all result / error dialogs.
/// * **[ScanErrorHandler]** — error-message routing.
/// * **[ScanOverlayPainter]** — camera overlay graphic.
/// * **[ScannerFooter]** — torch button and instruction label.
/// * **[PermissionDeniedView]** — camera-denied fallback.
class QRCodeScreen extends StatefulWidget {
  const QRCodeScreen({super.key});

  @override
  State<QRCodeScreen> createState() => _QRCodeScreenState();
}

class _QRCodeScreenState extends State<QRCodeScreen> with ScanDialogsMixin {
  // ─── STATE VARIABLES ──────────────────────────────────────────────────────

  /// Forces [MobileScanner] to re-mount when changed (used on permission retry).
  Key _scannerKey = UniqueKey();

  /// Side length (in logical pixels) of the square scan-window cutout.
  static const double _scanAreaSize = 250.0;

  late MobileScannerController _cameraController;

  /// `null`  — permission decision is pending (show spinner).
  /// `true`  — camera access granted.
  /// `false` — camera access denied.
  bool? _cameraPermissionGranted;

  /// Whether the scanner should process newly detected barcodes.
  bool _isScanning = true;

  /// Whether a landmark API call is in progress.
  bool _isLoading = false;

  /// Stores the last camera error message for on-screen debugging.
  /// Visible to the user so we can diagnose iOS / Safari issues remotely.
  String? _cameraErrorMessage;

  /// iOS Safari often blocks auto-start even after permission is granted.
  /// When true, we show a "Tap to Start Camera" button instead of the spinner.
  bool _needsManualStart = false;

  // ─── LIFECYCLE ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _initController();
    _checkAndShowSafetyReminder();
    // iOS Safari guard: if the camera hasn't auto-initialised within 3 seconds,
    // surface a manual-start button (Safari blocks camera without a user tap).
    if (kIsWeb) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _cameraPermissionGranted == null) {
          setState(() => _needsManualStart = true);
        }
      });
    }
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  /// Creates and registers a fresh [MobileScannerController].
  void _initController() {
    _cameraController = MobileScannerController();
    _cameraController.addListener(_onControllerStateChanged);
  }

  /// Attempts to start the camera inside a try/catch.
  ///
  /// Called when the user taps the manual-start button (iOS Safari workaround).
  Future<void> _startCamera() async {
    if (!mounted) return;
    setState(() {
      _needsManualStart = false;
      _cameraPermissionGranted = null; // Show spinner while starting.
      _cameraErrorMessage = null;
    });
    try {
      await _cameraController.start();
    } catch (e) {
      if (mounted) {
        setState(() {
          _cameraPermissionGranted = false;
          _cameraErrorMessage = 'Start error: $e';
        });
      }
    }
  }

  /// Removes the listener and disposes the current [MobileScannerController].
  void _disposeController() {
    _cameraController.removeListener(_onControllerStateChanged);
    _cameraController.dispose();
  }

  /// Reacts to [MobileScannerController] state changes.
  ///
  /// Updates [_cameraPermissionGranted] when the controller reports
  /// initialisation or an error.
  ///
  /// > **Note (web):** Permission denial may not surface here — it can arrive
  /// > as an exception inside the widget's build cycle instead. That case is
  /// > caught by [_onScannerError] via `MobileScanner.errorBuilder`.
  void _onControllerStateChanged() {
    final state = _cameraController.value;
    if (!mounted) return;

    if (state.isInitialized) {
      setState(() {
        _cameraPermissionGranted = true;
        _needsManualStart = false;
        _cameraErrorMessage = null;
      });
    } else if (state.error != null && _cameraPermissionGranted != true) {
      final errMsg = state.error.toString();
      setState(() {
        _cameraPermissionGranted = false;
        _cameraErrorMessage = errMsg;
      });
    }
  }

  /// [MobileScanner.errorBuilder] callback.
  ///
  /// Called when the scanner widget itself raises an error — most commonly a
  /// `NotAllowedError` (permission denied) on web where `getUserMedia` is
  /// rejected. Returns an invisible placeholder so the camera layer does not
  /// crash the tree.
  Widget _onScannerError(BuildContext context, MobileScannerException error) {
    // Capture the human-readable error so we can display it on-screen.
    // This is critical for diagnosing iOS Safari black-screen issues remotely.
    final errMsg =
        'Camera error: ${error.errorCode.name} — ${error.errorDetails?.message ?? 'No details'}';
    if (_cameraPermissionGranted != false) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _cameraPermissionGranted != false) {
          setState(() {
            _cameraPermissionGranted = false;
            _cameraErrorMessage = errMsg;
          });
        }
      });
    }
    return const SizedBox.expand();
  }

  /// Checks whether the safety-reminder dialog has already been shown for
  /// this student account. If not, marks it shown and presents the dialog.
  ///
  /// Uses a per-student [SharedPreferences] key so the reminder only fires
  /// once per account. Failures are swallowed silently — the reminder is
  /// non-critical and must not block scanning.
  Future<void> _checkAndShowSafetyReminder() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;

      const key = 'safety_reminder_shown'; // ← device-scoped, no network needed
      if (prefs.getBool(key) ?? false) return;

      await prefs.setBool(key, true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) showSafetyReminderDialog();
      });
    } catch (_) {
      // Non-critical — silently skip if prefs access fails.
    }
  }

  // ─── BUILD ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBlack,

      // ── APP BAR ──────────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Image.asset('assets/images/nav_logo.png', height: 40),
      ),
      body: _buildBody(context),
    );
  }

  /// Assembles the layered camera UI.
  ///
  /// Layer order (bottom → top):
  /// 1. [MobileScanner] camera feed — always mounted.
  /// 2. [ScanOverlayPainter] — scan-zone guide (camera active only).
  /// 3. Permission-pending spinner.
  /// 4. [PermissionDeniedView] — covers camera when access is denied.
  /// 5. [ScannerFooter] — torch button (camera active only).
  /// 6. Loading overlay — shown while an API call is in flight.
  Widget _buildBody(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    const appBarHeight = kToolbarHeight;

    // scanWindow restricts native barcode detection to the visible square.
    // Web ignores this — the full frame is always decoded there.
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
        // ── 1. CAMERA ────────────────────────────────────────────────────────
        MobileScanner(
          key: _scannerKey,
          controller: _cameraController,
          fit: BoxFit.cover,
          scanWindow: scanWindow,
          errorBuilder: _onScannerError,
          onDetect: (capture) {
            if (!_isScanning || _cameraPermissionGranted != true) return;
            final value = capture.barcodes.firstOrNull?.rawValue;
            if (value != null && value.isNotEmpty) _handleScan(value);
          },
        ),

        // ── 2. SCAN OVERLAY ───────────────────────────────────────────────
        if (_cameraPermissionGranted == true)
          CustomPaint(
            painter: ScanOverlayPainter(
              scanAreaSize: _scanAreaSize,
              borderColor: AppColors.maroon,
            ),
          ),

        // ── 3. PERMISSION PENDING / iOS Safari manual-start ───────────────
        if (_cameraPermissionGranted == null)
          ColoredBox(
            color: Colors.black,
            child: Center(
              child: _needsManualStart
                  // iOS Safari: camera blocked until the user taps.
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.camera_alt_outlined,
                            color: Colors.white54,
                            size: 64,
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Camera requires a tap to start on this browser.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 28),
                          ElevatedButton.icon(
                            onPressed: _startCamera,
                            icon: const Icon(Icons.play_circle_outline),
                            label: const Text('Start Scanner'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8B0000),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const CircularProgressIndicator(color: Colors.white),
            ),
          ),

        // ── 4. PERMISSION DENIED ──────────────────────────────────────────
        if (_cameraPermissionGranted == false)
          ColoredBox(
            color: Colors.black,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PermissionDeniedView(onRetry: _retryPermission),
                // Error details — useful for remote diagnosis of iOS issues.
                if (_cameraErrorMessage != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _cameraErrorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

        // ── 5. SCANNER FOOTER ─────────────────────────────────────────────
        if (_cameraPermissionGranted == true)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ScannerFooter(controller: _cameraController),
          ),

        // ── 6. LOADING OVERLAY ────────────────────────────────────────────
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

  // ─── SCAN HANDLING ────────────────────────────────────────────────────────

  /// Processes a raw QR code value detected by [MobileScanner].
  ///
  /// 1. Pauses scanning and shows the loading overlay.
  /// 2. Calls [LandmarkApi.visitLandmark] with the scanned [qrCode].
  /// 3. On success, shows [showSuccessDialog].
  /// 4. On failure, delegates to [ScanErrorHandler] to pick the right dialog.
  /// 5. Always hides the loading overlay when done.
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
      showSuccessDialog(
        result: result,
        onReset: _resetScanner,
        onViewLandmark: _navigateToLandmarkDetails,
      );
    } catch (e) {
      if (!mounted) return;
      ScanErrorHandler.handle(
        e,
        onAlreadyVisited: () =>
            showAlreadyVisitedDialog(onReset: _resetScanner),
        onInvalidQr: () => showInvalidQrDialog(onReset: _resetScanner),
        onGenericError: () => showErrorDialog(onReset: _resetScanner),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Disposes and recreates the scanner controller to retry camera permission.
  ///
  /// On web, recreating the controller re-calls `getUserMedia`, which
  /// re-triggers the browser permission prompt.
  ///
  /// > **Note:** If the user has permanently denied camera access in their
  /// > browser/OS settings, the prompt will not reappear. The
  /// > [PermissionDeniedView] message already guides them to settings.
  void _retryPermission() {
    if (_isLoading) return;

    _disposeController();
    _initController();
    setState(() {
      _cameraPermissionGranted = null;
      _scannerKey = UniqueKey();
    });
  }

  /// Resumes scanning after a dialog is dismissed.
  void _resetScanner() {
    _cameraController.start();
    setState(() => _isScanning = true);
  }

  // ─── NAVIGATION ───────────────────────────────────────────────────────────

  /// Navigates to [LandmarkDetailView] for the given [landmarkData].
  ///
  /// Replaces the current route with [DashboardScreen] (Landmarks tab),
  /// then immediately pushes [LandmarkDetailView] on top via
  /// `addPostFrameCallback` to ensure the new route is fully mounted first.
  void _navigateToLandmarkDetails(Map<String, dynamic> landmarkData) {
    final navigator = Navigator.of(context);

    navigator.pushReplacement(
      MaterialPageRoute(builder: (_) => const DashboardScreen(initialTab: 1)),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      navigator.push(
        MaterialPageRoute(
          builder: (_) => LandmarkDetailView(
            landmark: LandmarkSummary(
              landmarkId: landmarkData['landmark_id'] as int,
              name: landmarkData['name'].toString(),
              imgPath: landmarkData['img_path'] as String?,
              isVisited: true,
            ),
          ),
        ),
      );
    });
  }
}
