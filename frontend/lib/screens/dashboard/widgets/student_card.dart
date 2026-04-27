import 'package:flutter/material.dart';

class StudentCard extends StatelessWidget {
  final String name;
  final String studentNumber;
  final String program;
  final String specialization;
  final String? imgPath;

  const StudentCard({
    super.key,
    required this.name,
    required this.studentNumber,
    required this.program,
    required this.specialization,
    this.imgPath,
  });

  static const _maroon = Color(0xFF7A1D1D);
  static const _gradientTop = Color(0xFFA62121);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_gradientTop, _maroon],
        ),
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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.60),
                    width: 2,
                  ),
                  image: imgPath != null
                      ? DecorationImage(
                          image: NetworkImage(imgPath!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: imgPath == null
                    ? const Icon(
                        Icons.person_outline,
                        color: Colors.white,
                        size: 32,
                      )
                    : null,
              ),
              const SizedBox(width: 20),

              // Name + Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isEmpty ? 'Student' : name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                    if (studentNumber.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        studentNumber,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          height: 1.1,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    if (program.isNotEmpty)
                      Text(
                        program,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    if (specialization.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        specialization,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
