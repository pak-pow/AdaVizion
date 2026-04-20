import 'package:flutter/material.dart';

enum QuizState { locked, unlocked, completed }

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  // --- BRAND COLORS ---
  static const _maroon = Color(0xFF7A1D1D);
  static const _maroonDark = Color(0xFF4A0F0F);
  static const _gradientTop = Color(0xFFA62121);
  static const _headerGrey = Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,

      // --- APP BAR ---
      appBar: AppBar(
        backgroundColor: _headerGrey,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Image.asset('assets/images/nav_logo.png', height: 42),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. THE RED HEADER BOX
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [_gradientTop, _maroon],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: const Column(
                children: [
                  Text(
                    'Quiz',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                    ),
                  ),
                  Text(
                    'answer and earn points',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 2. HARDCODED QUIZ 1 CARD — "Way of the Envergan"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: _buildQuizCard(
                state: QuizState.unlocked,
                title: 'Way of the Envergan',
                hint: 'Requires 3 landmark visits • 10 questions',
              ),
            ),

            const SizedBox(height: 32),

            // 3. FOOTER
            const Text(
              'Go back',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: _maroon,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'to unlock quizzes and explore\nEnverga University',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: _maroon,
              ),
            ),
            const SizedBox(height: 16),

            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: _maroonDark,
                side: const BorderSide(color: _maroonDark, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(180, 45),
                padding: const EdgeInsets.symmetric(horizontal: 24),
              ),
              child: const Text(
                'Return to Dashboard',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // QUIZ CARD COMPONENT
  // ==========================================
  Widget _buildQuizCard({
    required QuizState state,
    required String title,
    required String hint,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- THE INNER BUTTON ---
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: state == QuizState.locked
                  ? Colors.grey.shade400
                  : _maroonDark,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(child: _buildInnerButtonContent(state)),
          ),

          const SizedBox(height: 16),

          // --- TEXT BLOCK ---
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: _maroonDark,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            hint,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: _maroonDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInnerButtonContent(QuizState state) {
    if (state == QuizState.locked) {
      return const Icon(Icons.lock_outline, color: Colors.white, size: 32);
    }
    final buttonText = state == QuizState.completed ? 'Completed' : 'Take Quiz';
    return Text(
      buttonText,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 26,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}
