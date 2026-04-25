import 'package:flutter/material.dart';
import '../widgets/auth_text_field.dart';
import '../../../utils/toast_service.dart';

// ============================================================================
// AUTH LAYOUT VIEW
//
// Extracted from login_screen.dart _buildAuthLayout() + _buildAuthCardContent()
// (lines 421–857).
//
// Contains the Login/Signup form card. Receives all controllers, dropdown
// state, loading flag, and submit callback from the parent shell so it owns
// zero business logic itself.
//
// The _backendPrograms and _backendSpecializations maps are moved here as
// top-level constants since they are only ever read from within this widget.
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
///
/// Stateless — all mutable state (controllers, loading, dropdowns) is owned
/// by [_AuthScreenState] and forwarded here as params. This keeps business
/// logic (AuthApi calls, navigation) entirely in the parent shell.
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
  /// The parent shell owns the actual AuthApi call and navigation.
  final Future<void> Function() onSubmit;

  // ─── Brand colours ─────────────────────────────────────────────────────────
  static const _maroon = Color(0xFF7A1D1D);
  static const _maroonDark = Color(0xFF5D1414);

  @override
  Widget build(BuildContext context) {
    final border = authInputBorder();
    final size = MediaQuery.of(context).size;

    return Column(
      children: [
        const SizedBox(height: 24),

        // Dynamic Titles: Renders the image logo for login, and text for signup
        if (isLogin)
          Center(child: Image.asset('assets/images/title.png', height: 100))
        else
          const Text(
            'Welcome to\nEUventure',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: _maroon,
              height: 1.1,
            ),
          ),

        const SizedBox(height: 32),

        // --- Z-INDEX LAYERING (Mascot & Card) ---
        Stack(
          clipBehavior:
              Clip.none, // Allows the massive mascot to bleed off the edges
          alignment: Alignment.topCenter,
          children: [
            // LAYER 1 (BACK): The Mascot
            Positioned(
              top: -112,
              left: 5,
              right: 5,
              child: RepaintBoundary(
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),

            // LAYER 2 (FRONT): The Form Card
            Container(
              margin: const EdgeInsets.only(
                top: 150,
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
      ],
    );
  }

  // ─── Card content (inputs + submit button) ─────────────────────────────────
  Widget _buildCardContent(BuildContext context, OutlineInputBorder border, Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          isLogin ? 'Sign in' : 'Sign up',
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: _maroon,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          isLogin
              ? 'to explore and learn in Enverga\nUniversity'
              : 'and get ready to explore\nwith us',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: _maroon,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),

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

          // DYNAMIC PROGRAM DROPDOWN
          AuthDropdownField(
            hint: 'Course/Program',
            items: kBackendPrograms.entries
                .map(
                  (e) => DropdownMenuItem(
                    value: e.key, // Sends 'BSCS' to backend
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

          // DYNAMIC SPECIALIZATION DROPDOWN (Only shows if selected program has subs)
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
            hint: 'Student ID',
            icon: Icons.email_outlined,
            border: border,
            maxLength: 15,
          ),
          const SizedBox(height: 12),
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
                style: TextStyle(color: _maroon, fontSize: 10),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],

        // --- SUBMIT BUTTON ---
        ElevatedButton(
          onPressed: isLoading ? null : onSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: _maroonDark,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
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
              : Text(
                  isLogin ? 'Continue' : 'Confirm',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ],
    );
  }
}
