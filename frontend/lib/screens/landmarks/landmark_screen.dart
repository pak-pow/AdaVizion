import 'package:flutter/material.dart';
import '../../../services/api/landmark_api.dart';
import 'landmark_constants.dart';
import 'models/landmark_model.dart';
import 'views/landmark_detail_view.dart';
import 'widgets/landmark_card.dart';
import 'widgets/shared/landmark_error_state.dart';

// ─── Landmark screen ──────────────────────────────────────────────────────────

/// Root screen for the Campus Landmarks feature.
///
/// Fetches the full checklist via [LandmarkApi.getChecklist] and renders a
/// scrollable list of [LandmarkCard]s topped by a progress header.
class LandmarkScreen extends StatefulWidget {
  const LandmarkScreen({super.key});

  @override
  State<LandmarkScreen> createState() => _LandmarkScreenState();
}

class _LandmarkScreenState extends State<LandmarkScreen> {
  late Future<List<LandmarkSummary>> _checklistFuture;

  @override
  void initState() {
    super.initState();
    _checklistFuture = _fetchChecklist();
  }

  // ─── Data ──────────────────────────────────────────────────────────────────

  Future<List<LandmarkSummary>> _fetchChecklist() async {
    final raw = await LandmarkApi.getChecklist();
    return raw
        .map((e) => LandmarkSummary.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Triggers a full data reload and rebuilds the widget tree.
  Future<void> _refresh() async {
    setState(() => _checklistFuture = _fetchChecklist());
  }

  // ─── Navigation ────────────────────────────────────────────────────────────

  void _openDetail(LandmarkSummary landmark) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LandmarkDetailView(landmark: landmark)),
    );
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: FutureBuilder<List<LandmarkSummary>>(
        future: _checklistFuture,
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
              onRetry: _refresh,
            );
          }

          final landmarks = snapshot.data!;

          // ── Empty ───────────────────────────────────────────────────────────
          if (landmarks.isEmpty) return const _EmptyState();

          // ── List ────────────────────────────────────────────────────────────
          final visited = landmarks.where((l) => l.isVisited).length;

          return RefreshIndicator(
            color: kLandmarkMaroon,
            onRefresh: _refresh,
            child: CustomScrollView(
              slivers: [
                // ── Progress header ─────────────────────────────────────────
                SliverToBoxAdapter(
                  child: _ProgressHeader(
                    visited: visited,
                    total: landmarks.length,
                  ),
                ),

                // ── Landmark list ───────────────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final landmark = landmarks[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: LandmarkCard(
                          landmark: landmark,
                          onTap: () => _openDetail(landmark),
                        ),
                      );
                    }, childCount: landmarks.length),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Progress header ──────────────────────────────────────────────────────────

/// Displays the screen title, subtitle, and an animated visited/total progress
/// bar at the top of the landmark list.
class _ProgressHeader extends StatelessWidget {
  final int visited;
  final int total;

  const _ProgressHeader({required this.visited, required this.total});

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : visited / total;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Campus Landmarks',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: kLandmarkMaroon,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Scan QR codes around campus to discover each landmark.',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),

          // ── Animated progress bar ─────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: progress),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) => LinearProgressIndicator(
                      value: value,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        kLandmarkMaroon,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$visited / $total',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: kLandmarkMaroon,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

/// Shown when the API returns an empty landmark list.
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.place_rounded, size: 56, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No landmarks found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
