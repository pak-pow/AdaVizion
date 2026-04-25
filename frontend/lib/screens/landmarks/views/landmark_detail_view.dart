import 'package:flutter/material.dart';
import '../../../services/api/landmark_api.dart';
import '../landmark_constants.dart';
import '../models/landmark_model.dart';
import '../utils/landmark_name_parser.dart';
import '../widgets/shared/landmark_error_state.dart';
import '../widgets/shared/landmark_image_fallback.dart';

// ─── Landmark detail view ─────────────────────────────────────────────────────

/// Full-screen detail for a single landmark, reachable only after the student
/// has scanned its QR code.
///
/// Fetches [LandmarkDetail] from [LandmarkApi.getLandmark] and renders a
/// collapsing hero image, description, and fun-fact card.
class LandmarkDetailView extends StatefulWidget {
  final LandmarkSummary landmark;

  const LandmarkDetailView({super.key, required this.landmark});

  @override
  State<LandmarkDetailView> createState() => _LandmarkDetailViewState();
}

class _LandmarkDetailViewState extends State<LandmarkDetailView> {
  late Future<LandmarkDetail> _detailFuture;

  @override
  void initState() {
    super.initState();
    _detailFuture = _fetchDetail();
  }

  // ─── Data ──────────────────────────────────────────────────────────────────

  Future<LandmarkDetail> _fetchDetail() async {
    final raw = await LandmarkApi.getLandmark(widget.landmark.landmarkId);
    return LandmarkDetail.fromJson(raw);
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: FutureBuilder<LandmarkDetail>(
        future: _detailFuture,
        builder: (context, snapshot) {
          // ── Loading ─────────────────────────────────────────────────────────
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: kLandmarkMaroon),
            );
          }

          // ── Error ───────────────────────────────────────────────────────────
          if (snapshot.hasError) {
            return LandmarkErrorState(
              error: snapshot.error.toString(),
              onBack: () => Navigator.pop(context),
            );
          }

          final detail = snapshot.data!;

          // ── Content ─────────────────────────────────────────────────────────
          return CustomScrollView(
            slivers: [
              // ── Hero image + back button ──────────────────────────────────
              _HeroSliver(imgPath: detail.imgPath, name: detail.name),

              // ── Body ─────────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 48),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // ── Description ──────────────────────────────────────
                      const _SectionLabel(label: 'About'),
                      const SizedBox(height: 8),
                      Text(
                        detail.description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade700,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Fun fact ─────────────────────────────────────────
                      _FunFactCard(funFact: detail.funFact),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Hero sliver ─────────────────────────────────────────────────────────────

/// Collapsing [SliverAppBar] showing the landmark photo, a maroon gradient
/// overlay, and a parsed title/subtitle derived via [parseLandmarkName].
class _HeroSliver extends StatelessWidget {
  final String? imgPath;
  final String name;

  const _HeroSliver({required this.imgPath, required this.name});

  @override
  Widget build(BuildContext context) {
    final hasImage = imgPath != null && imgPath!.isNotEmpty;
    final parsed = parseLandmarkName(name);

    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      centerTitle: true,
      backgroundColor: kLandmarkMaroon,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: CircleAvatar(
          backgroundColor: Colors.black26,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        // Zero out default padding — internal centering is handled manually.
        titlePadding: EdgeInsets.zero,
        title: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  parsed.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.2,
                    shadows: [Shadow(blurRadius: 6, color: Colors.black54)],
                  ),
                ),
                if (parsed.subtitle != null)
                  Text(
                    '(${parsed.subtitle})',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                      height: 1.4,
                      shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
                    ),
                  ),
              ],
            ),
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            hasImage
                ? Image.network(
                    imgPath!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const LandmarkImageFallback(iconSize: 64),
                  )
                : const LandmarkImageFallback(iconSize: 64),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.55, 0.78, 0.90, 1.0],
                    colors: [
                      Colors.transparent,
                      kLandmarkMaroonDark.withValues(alpha: 0.53),
                      kLandmarkMaroonDark.withValues(alpha: 0.80),
                      kLandmarkMaroonDark,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section label ────────────────────────────────────────────────────────────

/// Small all-caps heading used above content sections (e.g. "ABOUT").
class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: kLandmarkMaroon,
      ),
    );
  }
}

// ─── Fun fact card ────────────────────────────────────────────────────────────

/// Green-tinted card that highlights an interesting fact about the landmark.
class _FunFactCard extends StatelessWidget {
  final String funFact;

  const _FunFactCard({required this.funFact});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kFunFactMint,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kFunFactSage),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lightbulb_outline, color: kFunFactGreen, size: 18),
              SizedBox(width: 8),
              Text(
                'DID YOU KNOW?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: kFunFactGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            funFact,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: kFunFactDeep,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
