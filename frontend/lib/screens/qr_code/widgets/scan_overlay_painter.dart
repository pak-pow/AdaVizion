// ─── SCAN OVERLAY PAINTER ─────────────────────────────────────────────────

import 'package:flutter/material.dart';

/// Draws a semi-transparent dark overlay over the entire camera preview,
/// then "punches out" a clear rounded rectangle in the centre — the scan zone.
///
/// ### Platform behaviour
/// * **Native (iOS / Android)** — the cutout aligns with the `scanWindow` rect
///   passed to `MobileScanner`, which restricts actual barcode detection to
///   the visible box.
/// * **Web** — visual guide only. The `mobile_scanner` web backend does not
///   honour `scanWindow`, so the full camera frame is always decoded.
class ScanOverlayPainter extends CustomPainter {
  /// Creates a [ScanOverlayPainter].
  ///
  /// - [scanAreaSize] is the side length of the transparent cutout square.
  /// - [borderColor] is the colour drawn around the cutout border.
  const ScanOverlayPainter({
    required this.scanAreaSize,
    required this.borderColor,
  });

  /// Side length of the square scan-window cutout, in logical pixels.
  final double scanAreaSize;

  /// Colour of the rounded-rectangle border drawn around the scan zone.
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

    // Even-odd fill: full-screen rect minus the cutout = dark surround.
    final overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(rrect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(overlayPath, overlayPaint);
    canvas.drawRRect(rrect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant ScanOverlayPainter oldDelegate) =>
      oldDelegate.scanAreaSize != scanAreaSize ||
      oldDelegate.borderColor != borderColor;
}
