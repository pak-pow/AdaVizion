import 'package:flutter/material.dart';
import 'package:adavizion/theme/app_colors.dart';

class StudentStats extends StatelessWidget {
  final int level;
  final int currentXp;
  final int landmarksVisited;
  final int landmarksTotal;
  final int quizPoints;

  const StudentStats({
    super.key,
    required this.level,
    required this.currentXp,
    required this.landmarksVisited,
    required this.landmarksTotal,
    required this.quizPoints,
  });

  @override
  Widget build(BuildContext context) {
    final xpProgress = (currentXp / 500.0).clamp(0.0, 1.0);

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
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '$currentXp / 500 XP',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildAnimatedBar(xpProgress, AppColors.green, AppColors.borderLight),
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
                color: AppColors.maroon,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildCompactStatCard(
                label: 'Quiz Scores',
                value: '$quizPoints pts',
                icon: Icons.emoji_events_rounded,
                color: AppColors.maroon,
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
                    color: AppColors.maroon,
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
                    color: AppColors.textSecondary,
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
