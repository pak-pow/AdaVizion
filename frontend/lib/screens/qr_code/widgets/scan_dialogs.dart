import 'package:flutter/material.dart';
import 'package:adavizion/theme/app_colors.dart';

/// Mixin that provides all scan-result dialog methods for [QRCodeScreen].
///
/// Separating dialog logic from the screen widget keeps [QRCodeScreen] focused
/// on camera lifecycle and scanning state, while this mixin owns the purely
/// presentational concern of showing feedback to the user.
///
/// ### Usage
/// ```dart
/// class _QRCodeScreenState extends State<QRCodeScreen>
///     with ScanDialogsMixin { … }
/// ```
///
/// Every method in this mixin requires [BuildContext] access via the `context`
/// getter, which is supplied automatically when mixed into a [State] subclass.
mixin ScanDialogsMixin<T extends StatefulWidget> on State<T> {
  // ─── PRIVATE HELPERS ──────────────────────────────────────────────────────

  /// Low-level dialog builder shared by all scan-result dialogs.
  ///
  /// Parameters:
  /// * [title] — Heading text shown in the dialog header.
  /// * [content] — Optional body widget rendered below the header.
  /// * [actions] — Buttons rendered in the dialog footer.
  /// * [isDarkHeader] — When `true`, the header uses [QRCodeConstants.maroonDark]
  ///   as its background; otherwise the header is white with maroon text.
  Future<V?> _showScanDialog<V>({
    required String title,
    Widget? content,
    required List<Widget> actions,
    bool isDarkHeader = false,
  }) {
    return showDialog<V>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: EdgeInsets.zero,
        contentPadding: EdgeInsets.zero,
        actionsPadding: EdgeInsets.zero,
        backgroundColor: Colors.white,
        title: _DialogHeader(title: title, isDark: isDarkHeader),
        content: content,
        actions: actions,
      ),
    );
  }

  /// Builds a branded [ElevatedButton] or [OutlinedButton].
  ///
  /// Parameters:
  /// * [label] — Button label text.
  /// * [onPressed] — Tap callback.
  /// * [isSecondary] — `true` for an outlined (secondary) style; `false` for
  ///   a filled maroon (primary) style.
  /// * [fullWidth] — Pass `true` when the button is wrapped in an [Expanded]
  ///   widget so it fills its available cell. Leave `false` for centred
  ///   standalone buttons.
  Widget buildDialogButton({
    required String label,
    required VoidCallback onPressed,
    bool isSecondary = false,
    bool fullWidth = false,
  }) {
    final double? width = fullWidth ? double.infinity : null;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    );

    if (isSecondary) {
      return SizedBox(
        width: width,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.maroonDark,
            side: const BorderSide(color: AppColors.maroonDark, width: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: shape,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            softWrap: true,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.maroonDark,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: shape,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          softWrap: true,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  /// Dismisses the current dialog, then executes [action].
  ///
  /// Use this in dialog button callbacks to guarantee the dialog is popped
  /// before any state change or navigation occurs.
  void closeDialogAnd(VoidCallback action) {
    Navigator.pop(context);
    action();
  }

  // ─── PUBLIC DIALOG METHODS ────────────────────────────────────────────────

  /// Shows the "Landmark Unlocked!" success dialog after a successful scan.
  ///
  /// Displays the landmark name, a fun-fact card, and the XP earned. Offers
  /// "Close" (which resets the scanner) and "View" (which navigates
  /// to [LandmarkDetailView]).
  ///
  /// - [result] is the decoded API response from `LandmarkApi.visitLandmark`.
  /// - [onReset] resets the scanner to resume scanning after the dialog closes.
  /// - [onViewLandmark] navigates to the landmark detail screen.
  void showSuccessDialog({
    required Map<String, dynamic> result,
    required VoidCallback onReset,
    required void Function(Map<String, dynamic>) onViewLandmark,
  }) {
    final landmark = result['landmark'] as Map<String, dynamic>;
    final progress = result['progress'] as Map<String, dynamic>;
    final xpEarned = (progress['xp'] as Map?)?['earned'] ?? 0;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        titlePadding: EdgeInsets.zero,
        contentPadding: EdgeInsets.zero,
        actionsPadding: EdgeInsets.zero,
        title: const _DialogHeader(title: "Landmark Unlocked!", isDark: true),
        content: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── LANDMARK NAME ────────────────────────────────────────
                Text(
                  landmark['name'].toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.maroon,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 16),

                // ── FUN FACT CARD ─────────────────────────────────────────
                _FunFactCard(text: landmark['fun_fact'].toString()),
                const SizedBox(height: 16),

                // ── XP PILL ───────────────────────────────────────────────
                _XpPill(xpEarned: xpEarned),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: buildDialogButton(
                      label: "Close",
                      isSecondary: true,
                      fullWidth: true,
                      onPressed: () => closeDialogAnd(onReset),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: buildDialogButton(
                      label: "View",
                      fullWidth: true,
                      onPressed: () =>
                          closeDialogAnd(() => onViewLandmark(landmark)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).then((_) => onReset());
  }

  /// Shows a dialog when the scanned QR code is not a recognised landmark.
  ///
  /// - [onReset] resumes scanning when the user taps "Scan Again".
  void showInvalidQrDialog({required VoidCallback onReset}) {
    _showScanDialog(
      title: "Invalid QR Code!",
      isDarkHeader: true,
      content: const Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Text(
          "This doesn't seem to be a valid landmark QR code. "
          "Please try scanning again.",
          textAlign: TextAlign.center,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildDialogButton(
                label: "Scan Again",
                onPressed: () => closeDialogAnd(onReset),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Shows a dialog when the user scans a landmark they have already visited.
  ///
  /// - Offers two options: navigate back (via [Navigator.pop]) or resume
  /// scanning via [onReset].
  void showAlreadyVisitedDialog({required VoidCallback onReset}) {
    _showScanDialog(
      title: "Already Visited!",
      actions: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: buildDialogButton(
                    label: "Close",
                    isSecondary: true,
                    fullWidth: true,
                    onPressed: () =>
                        closeDialogAnd(() => Navigator.pop(context)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: buildDialogButton(
                    label: "Scan Another",
                    fullWidth: true,
                    onPressed: () => closeDialogAnd(onReset),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Shows a generic error dialog for network or server failures.
  ///
  /// - [onReset] resumes scanning when the user taps "Try Again".
  void showErrorDialog({required VoidCallback onReset}) {
    _showScanDialog(
      title: "Something Went Wrong!",
      isDarkHeader: true,
      content: const Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Text(
          "Couldn't connect to the server. "
          "Check your connection and try again.",
          textAlign: TextAlign.center,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildDialogButton(
                label: "Try Again",
                onPressed: () => closeDialogAnd(onReset),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Shows a one-time safety reminder dialog.
  ///
  /// - The caller is responsible for deciding when this dialog should appear
  /// (e.g. checking a [SharedPreferences] flag before calling).
  void showSafetyReminderDialog() {
    _showScanDialog(
      title: 'Safety First',
      isDarkHeader: true,
      content: const Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.health_and_safety_outlined,
              size: 48,
              color: AppColors.maroonDark,
            ),
            SizedBox(height: 16),
            Text(
              "Please be aware of your surroundings while scanning "
              "QR codes around campus.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            SizedBox(height: 8),
            Text(
              "Do not use the scanner while walking or in unsafe areas.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildDialogButton(
                      label: "Got it",
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── PRIVATE HELPER WIDGETS ───────────────────────────────────────────────────

/// Rounded header strip used at the top of every scan dialog.
class _DialogHeader extends StatelessWidget {
  const _DialogHeader({required this.title, required this.isDark});

  final String title;

  /// When `true`, the header has a dark maroon background with white text.
  /// When `false`, the header is white with dark maroon text.
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.maroonDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: isDark ? Colors.white : AppColors.maroonDark,
        ),
      ),
    );
  }
}

/// A soft mint-green card that displays a landmark fun fact with a lightbulb icon.
class _FunFactCard extends StatelessWidget {
  const _FunFactCard({required this.text});

  /// The fun fact text to display.
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.funFactBGFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.funFactBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 16,
                color: AppColors.funFactIcon,
              ),
              SizedBox(width: 6),
              Text(
                "FUN FACT",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: AppColors.funFactIcon,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            text,
            textAlign: TextAlign.justify,
            style: const TextStyle(
              fontSize: 14,
              height: 1.45,
              color: AppColors.funFactBody,
            ),
          ),
        ],
      ),
    );
  }
}

/// A pill-shaped badge showing how much XP was earned for a scan.
class _XpPill extends StatelessWidget {
  const _XpPill({required this.xpEarned});

  /// The amount of XP earned, displayed as "+N XP earned".
  final dynamic xpEarned;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.maroon.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.maroon.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bolt, size: 16, color: AppColors.maroon),
          const SizedBox(width: 4),
          Text(
            "+$xpEarned XP earned",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColors.maroon,
            ),
          ),
        ],
      ),
    );
  }
}
