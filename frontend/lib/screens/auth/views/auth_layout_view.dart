import 'package:flutter/material.dart';
import '../widgets/auth_text_field.dart';
import '../../../utils/toast_service.dart';
import 'package:adavizion/theme/app_colors.dart';

// ============================================================================
// AUTH LAYOUT VIEW
//
// Extracted from login_screen.dart _buildAuthLayout() + _buildAuthCardContent()
//
// Contains the Login/Signup form card. Receives all controllers, dropdown
// state, loading flag, and submit callback from the parent shell so it owns
// zero business logic itself.
//
// Now supports a responsive 50/50 split layout for Desktop (>= 900px width).
// ============================================================================

// These maps directly mirror backend/src/constants/academic-maps.ts
const Map<String, String> kBackendPrograms = {
  'BSA': 'Bachelor of Accountancy',
  'ABCOMM': 'Bachelor of Arts in Communication',
  'ABEL': 'Bachelor of Arts in English Language',
  'ABPL': 'Bachelor of Arts in Political Science',
  'BAPSYCH': 'Bachelor of Arts in Psychology',
  'BCAED': 'Bachelor of Culture and Arts Education',
  'BEED': 'Bachelor of Elementary Education',
  'BFA': 'Bachelor of Fine Arts',
  'BLIS': 'Bachelor of Library and Information Science',
  'BMMA': 'Bachelor of Multimedia Arts',
  'BPE': 'Bachelor of Physical Education',
  'BSARCH': 'Bachelor of Science in Architecture',
  'BSBA': 'Bachelor of Science in Business Administration',
  'BSBIO': 'Bachelor of Science in Biology',
  'BSCE': 'Bachelor of Science in Civil Engineering',
  'BSCS': 'Bachelor of Science in Computer Science',
  'BSCpE': 'Bachelor of Science in Computer Engineering',
  'BSCrim': 'Bachelor of Science in Criminology',
  'BSEE': 'Bachelor of Science in Electrical Engineering',
  'BSECON': 'Bachelor of Science in Economics',
  'BSECE': 'Bachelor of Science in Electronics Engineering',
  'BSES': 'Bachelor of Science in Environmental Science',
  'BSGE': 'Bachelor of Science in Geodetic Engineering',
  'BSHM': 'Bachelor of Science in Hospitality Management',
  'BSIE': 'Bachelor of Science in Industrial Engineering',
  'BSIT': 'Bachelor of Science in Information Technology',
  'BSMA': 'Bachelor of Science in Management Accounting',
  'BSMarE': 'Bachelor of Science in Marine Engineering',
  'BSMT': 'Bachelor of Science in Marine Transportation',
  'BSME': 'Bachelor of Science in Mechanical Engineering',
  'BSMedT': 'Bachelor of Science in Medical Technology',
  'BSN': 'Bachelor of Science in Nursing',
  'BSOA': 'Bachelor of Science in Office Administration',
  'BSPA': 'Bachelor of Science in Public Administration',
  'BSED': 'Bachelor of Secondary Education',
  'BSTM': 'Bachelor of Science in Tourism Management',
};

const Map<String, List<String>> kBackendSpecializations = {
  'BFA': ['Visual Communication'],
  'BSBA': [
    'Financial Management',
    'Human Resource Management',
    'Marketing Management',
    'Operations Management',
  ],
  'BMMA': ['Game Design', 'Video Design', 'Visual Design'],
  'BSCS': ['Data Science', 'Software Engineering'],
  'BSIT': ['CISCO Networking', 'Web & Mobile Application'],
  'BSED': ['English', 'Filipino', 'Mathematics', 'Science', 'Social Studies'],
  'BSHM': ['Cruise Management', 'Culinary Arts'],
};

/// The login and signup form card.
class AuthLayoutView extends StatelessWidget {
  const AuthLayoutView({
    super.key,
    required this.isLogin,
    required this.isLoading,
    // Login fields
    required this.emailController,
    required this.loginPasswordController,
    // Signup fields
    required this.firstNameController,
    required this.middleNameController,
    required this.lastNameController,
    required this.studentIdController,
    required this.signupPasswordController,
    // Dropdown state
    required this.selectedProgram,
    required this.selectedSpecialization,
    required this.onProgramChanged,
    required this.onSpecializationChanged,
    // Submit
    required this.onSubmit,
  });

  final bool isLogin;
  final bool isLoading;

  // Login
  final TextEditingController emailController;
  final TextEditingController loginPasswordController;

  // Signup
  final TextEditingController firstNameController;
  final TextEditingController middleNameController;
  final TextEditingController lastNameController;
  final TextEditingController studentIdController;
  final TextEditingController signupPasswordController;

  // Dropdown
  final String? selectedProgram;
  final String? selectedSpecialization;
  final void Function(String?) onProgramChanged;
  final void Function(String?) onSpecializationChanged;

  /// Called when the user taps "Continue" / "Confirm".
  final Future<void> Function() onSubmit;



  @override
  Widget build(BuildContext context) {
    final border = authInputBorder();
    final size = MediaQuery.of(context).size;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 900) {
          return _buildDesktopLayout(context, border, size);
        } else {
          return _buildMobileLayout(context, border, size);
        }
      },
    );
  }

  // ─── Desktop Layout (6:4 Split) ──────────────────────────────────────────
  Widget _buildDesktopLayout(
    BuildContext context,
    OutlineInputBorder border,
    Size size,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    // Left panel 6, Right panel 4
    final splitLine = screenWidth * 0.6;

    return SizedBox(
      height: screenHeight,
      child: Stack(
        children: [
          // 1. Background split (Behind everything)
          Row(
            children: [
              Expanded(flex: 6, child: Container(color: Colors.white)),
              Expanded(flex: 4, child: Container(color: AppColors.maroon)),
            ],
          ),

          // LAYER 2: Large Mascot (Straddling center boundary)
          Positioned(
            left: splitLine - 240,
            top: 60 + ((screenHeight - 60) * 0.35) - 200,
            child: IgnorePointer(
              child: Transform.rotate(
                angle: -0.25,
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 450,
                  width: 450,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // LAYER 3: Foreground Content (Branding + Card)
          Row(
            children: [
              // LEFT SIDE (White background)
              Expanded(
                flex: 6,
                child: Container(
                  padding: const EdgeInsets.only(left: 80.0),
                  alignment: Alignment.centerLeft,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Welcome to',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w500,
                          color: AppColors.maroon,
                        ),
                      ),
                      const Text(
                        'EUventure',
                        style: TextStyle(
                          fontSize: 72,
                          fontWeight: FontWeight.w900,
                          color: AppColors.maroon,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Interactive University\nExploration Platform',
                        style: TextStyle(
                          fontSize: 22,
                          color: AppColors.maroon,
                          height: 1.4,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 64),
                      OutlinedButton(
                        onPressed: () {
                          ToastService.showInfo(
                            context,
                            'Discover the future of campus tours.',
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.maroon,
                          side: const BorderSide(color: AppColors.maroon, width: 2),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 48,
                            vertical: 24,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'About',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // RIGHT SIDE (Maroon background)
              Expanded(
                flex: 4,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        padding: const EdgeInsets.all(40.0), // 40px all sides
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 40,
                              offset: Offset(0, 20),
                            ),
                          ],
                        ),
                        child: _buildCardContent(
                          context,
                          border,
                          size,
                          isDesktop: true,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Mobile Layout (Original) ──────────────────────────────────────────────
  Widget _buildMobileLayout(
    BuildContext context,
    OutlineInputBorder border,
    Size size,
  ) {
    return Column(
      children: [
        const SizedBox(height: 48), // Top padding for mascot
        if (isLogin)
          Center(child: Image.asset('assets/images/title.png', height: 100))
        else
          const Text(
            'Welcome to\nEUventure',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: AppColors.maroon,
              height: 1.1,
            ),
          ),
        const SizedBox(height: 12), // Reduced gap below title
        Padding(
          padding: const EdgeInsets.only(
            top: 80,
          ), // Reduced spacing for peeking effect
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Positioned(
                top: -180, // Position higher for slight overlap
                left: 5,
                right: 5,
                child: RepaintBoundary(
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(
                  top: 90, // Reduced margin to pull card closer to mascot
                  left: 24,
                  right: 24,
                  bottom: 40,
                ),
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 15,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: _buildCardContent(context, border, size),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Card content (inputs + submit button) ─────────────────────────────────
  Widget _buildCardContent(
    BuildContext context,
    OutlineInputBorder border,
    Size size, {
    bool isDesktop = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          isLogin ? 'Sign in' : 'Sign up',
          style: TextStyle(
            fontSize: isDesktop ? 48 : 30,
            fontWeight: FontWeight.w900,
            color: AppColors.maroon,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          isLogin
              ? 'to explore and learn in Enverga\nUniversity'
              : 'and get ready to explore\nwith us',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.maroon,
            fontSize: isDesktop ? 13 : 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: isDesktop ? 40 : 24),

        // --- SIGN UP FIELDS ---
        if (!isLogin) ...[
          AuthTextField(
            controller: firstNameController,
            hint: 'First Name',
            border: border,
            maxLength: 50,
          ),
          const SizedBox(height: 12),
          AuthTextField(
            controller: middleNameController,
            hint: 'Middle Name (Optional)',
            border: border,
            maxLength: 50,
          ),
          const SizedBox(height: 12),
          AuthTextField(
            controller: lastNameController,
            hint: 'Last Name',
            border: border,
            maxLength: 50,
          ),
          const SizedBox(height: 12),
          AuthTextField(
            controller: studentIdController,
            hint: 'Student Id (e.g., A25-12345)',
            border: border,
            maxLength: 15,
          ),
          const SizedBox(height: 12),

          AuthDropdownField(
            hint: 'Course/Program',
            items: kBackendPrograms.entries
                .map(
                  (e) => DropdownMenuItem(
                    value: e.key,
                    child: Text(
                      e.value,
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            selectedValue: selectedProgram,
            border: border,
            onChanged: onProgramChanged,
          ),
          const SizedBox(height: 12),

          if (selectedProgram != null &&
              kBackendSpecializations.containsKey(selectedProgram)) ...[
            AuthDropdownField(
              hint: 'Specialization',
              items: kBackendSpecializations[selectedProgram]!
                  .map(
                    (s) => DropdownMenuItem(
                      value: s,
                      child: Text(
                        s,
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              selectedValue: selectedSpecialization,
              border: border,
              onChanged: onSpecializationChanged,
            ),
            const SizedBox(height: 12),
          ],

          AuthTextField(
            controller: signupPasswordController,
            hint: 'Strong Password',
            border: border,
            obscureText: true,
            maxLength: 64,
          ),
          const SizedBox(height: 24),
        ],

        // --- LOGIN FIELDS ---
        if (isLogin) ...[
          AuthTextField(
            controller: emailController,
            hint: isDesktop ? 'Enter your email' : 'Student ID',
            icon: Icons.email_outlined,
            border: border,
            maxLength: 15,
          ),
          SizedBox(height: isDesktop ? 20 : 12),
          AuthTextField(
            controller: loginPasswordController,
            hint: 'Password',
            icon: Icons.lock_outline,
            border: border,
            obscureText: true,
            maxLength: 64,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                ToastService.showInfo(context, 'Feature coming soon!');
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Forgot password?',
                style: TextStyle(color: AppColors.maroon, fontSize: 10),
              ),
            ),
          ),
          SizedBox(height: isDesktop ? 24 : 8),
        ],

        // --- SUBMIT BUTTON ---
        ElevatedButton(
          onPressed: isLoading ? null : onSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.maroonDark,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: isDesktop ? 18 : 12),
            minimumSize: const Size.fromHeight(45),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
            disabledBackgroundColor: Colors.grey.shade400,
          ),
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Confirm', // Standardized label
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
        ),
      ],
    );
  }
}
