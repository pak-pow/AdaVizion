import 'package:flutter/material.dart';

class StudentStats extends StatelessWidget {
  final int level;
  final int toNextLevel;
  final int landmarksVisited;
  final int landmarksTotal;
  final int quizPoints;

  const StudentStats({
    super.key,
    required this.level,
    required this.toNextLevel,
    required this.landmarksVisited,
    required this.landmarksTotal,
    required this.quizPoints,
  });

  static const _maroon = Color(0xFF7A1D1D);
  static const _green = Color(0xFF2E7D32);

  @override
  Widget build(BuildContext context) {
    final currentXP = (500 - toNextLevel).clamp(0, 500);
    final xpProgress = currentXP / 500.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. XP & Level Progress (Top Row)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Level $level',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  Text(
                    '$currentXP / 500 XP',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildAnimatedBar(xpProgress, _green, Colors.grey.shade200),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 2. Landmarks & Quiz Row (Bottom Row)
        Row(
          children: [
            Expanded(
              child: _buildCompactStatCard(
                label: 'Landmarks',
                value: '$landmarksVisited / $landmarksTotal',
                icon: Icons.location_on_rounded,
                color:
                    _maroon, // Changed from _amber to match "star" icon color
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildCompactStatCard(
                label: 'Quiz Scores',
                value: '$quizPoints pts',
                icon: Icons.emoji_events_rounded,
                color: _maroon,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompactStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _maroon,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBar(double progress, Color fill, Color bg) {
    return LayoutBuilder(
      builder: (context, constraints) => Container(
        height: 7,
        width: constraints.maxWidth,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOutCubic,
            builder: (context, val, child) => FractionallySizedBox(
              widthFactor: val.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: fill,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
