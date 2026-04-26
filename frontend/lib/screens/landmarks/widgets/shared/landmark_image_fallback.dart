import 'package:flutter/material.dart';

// ─── Image fallback ───────────────────────────────────────────────────────────

/// Displayed whenever a landmark image is missing or fails to load.
///
/// [iconSize] can be overridden — cards use `40`, the detail hero uses `64`.
class LandmarkImageFallback extends StatelessWidget {
  /// Size of the placeholder icon. Defaults to `40`.
  final double iconSize;

  const LandmarkImageFallback({super.key, this.iconSize = 40});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.grey.shade200,
      child: Center(
        child: Icon(Icons.place_rounded, size: iconSize, color: Colors.grey),
      ),
    );
  }
}
