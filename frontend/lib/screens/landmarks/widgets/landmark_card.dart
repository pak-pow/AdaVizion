import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:adavizion/theme/app_colors.dart';
import '../models/landmark_model.dart';
import 'shared/landmark_image_fallback.dart';

// ─── Landmark card ────────────────────────────────────────────────────────────

/// Grid/list card representing a single [LandmarkSummary].
///
/// Tapping is disabled and a blur + lock overlay is applied when
/// [landmark.isVisited] is `false`.
class LandmarkCard extends StatelessWidget {
  final LandmarkSummary landmark;

  /// Called when the card is tapped. Only reachable for visited landmarks.
  final VoidCallback? onTap;

  const LandmarkCard({super.key, required this.landmark, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isLocked = !landmark.isVisited;

    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── Image ──────────────────────────────────────────────────────
              _CardImage(imgPath: landmark.imgPath, isLocked: isLocked),

              // ── Bottom gradient + title ────────────────────────────────────
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _NameStrip(name: landmark.name, isLocked: isLocked),
              ),

              // ── Centered lock icon (locked only) ──────────────────────────
              if (isLocked) const Center(child: _LockBadge()),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Card image ───────────────────────────────────────────────────────────────

/// Renders the landmark photo. When [isLocked], applies a blur and a
/// semi-transparent maroon tint so the image is obscured.
class _CardImage extends StatelessWidget {
  final String? imgPath;
  final bool isLocked;

  const _CardImage({required this.imgPath, required this.isLocked});

  @override
  Widget build(BuildContext context) {
    final hasImage = imgPath != null && imgPath!.isNotEmpty;

    final image = hasImage
        ? Image.network(
            imgPath!,
            fit: BoxFit.cover,
            // ignore: unnecessary_underscores
            errorBuilder: (_, __, ___) => const LandmarkImageFallback(),
          )
        : const LandmarkImageFallback();

    if (!isLocked) return image;

    return Stack(
      fit: StackFit.expand,
      children: [
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: image,
        ),
        ColoredBox(color: AppColors.maroon.withValues(alpha: 0.45)),
      ],
    );
  }
}

// ─── Name strip ───────────────────────────────────────────────────────────────

/// Semi-transparent gradient strip at the bottom of the card showing the
/// landmark name. Text is dimmed when [isLocked].
class _NameStrip extends StatelessWidget {
  final String name;
  final bool isLocked;

  const _NameStrip({required this.name, required this.isLocked});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 24, 10, 10),
      child: Text(
        name,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: isLocked ? Colors.white60 : Colors.white,
          height: 1.3,
          shadows: const [Shadow(blurRadius: 4, color: Colors.black54)],
        ),
      ),
    );
  }
}

// ─── Lock badge ───────────────────────────────────────────────────────────────

/// Circular badge with a lock icon centered over locked landmark cards.
class _LockBadge extends StatelessWidget {
  const _LockBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.80),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.lock_rounded, color: AppColors.maroon, size: 28),
    );
  }
}
