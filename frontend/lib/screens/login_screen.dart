import 'package:flutter/material.dart';
import 'dashboard_screen.dart';

/// Defines the primary top-level views accessible via the Top Navigation Bar.
enum AppView { home, about, auth }

/// Defines the specific sub-states within the Authentication view.
enum AuthState { login, signup, success }

/// The main entry point for the unauthenticated user experience.
/// Handles routing between Home, About, and Auth screens within a single page architecture.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  
  // ─── STATE VARIABLES ────────────────────────────────────────────────────────
  // Default to the Auth view and Login state when the app launches
  AppView _currentView = AppView.auth;
  AuthState _authState = AuthState.login;

  // ─── TEXT CONTROLLERS ───────────────────────────────────────────────────────
  // Controllers read the text inputted by the user in the TextFields.
  final _emailController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  final _fullNameController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _signupPasswordController = TextEditingController();

  // Variables to hold the currently selected values from the dropdown menus
  String? _selectedProgram;
  String? _selectedSpecialization;

  // ─── MOCK DATA ──────────────────────────────────────────────────────────────
  // TODO: Replace these with dynamic API calls to the backend later
  final List<String> _programs = [
    'BS Computer Science (BSCS)',
    'BS Information Technology (BSIT)',
    'BS Information Systems (BSIS)',
  ];

  final List<String> _specializations = [
    'Software Engineering',
    'Network Administrator',
    'Data Analytics',
    'Generalist',
  ];

  // ─── BRANDING COLORS ────────────────────────────────────────────────────────
  // Static constants keep our color palette consistent and easy to update
  static const _maroon = Color(0xFF7A1D1D);
  static const _maroonDark = Color(0xFF5D1414);
  static const _gradientTop = Color(0xFFB72424);
  static const _gradientBottom = Color(0xFF5D1414);

  /// Always dispose of TextEditingControllers when the widget is destroyed
  /// to prevent severe memory leaks in the application.
  @override
  void dispose() {
    _emailController.dispose();
    _loginPasswordController.dispose();
    _fullNameController.dispose();
    _studentIdController.dispose();
    _signupPasswordController.dispose();
    super.dispose();
  }

  /// Reusable helper method to generate the standard subtle grey border
  /// for our input fields. Keeps our UI code DRY (Don't Repeat Yourself).
  OutlineInputBorder _border() => OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: Colors.grey.shade300),
  );

  @override
  Widget build(BuildContext context) {
    // Fetches the exact dimensions of the user's device screen
    final size = MediaQuery.of(context).size;

    return Scaffold(
      // The base background color acts as a fallback and hides the Android system bar
      backgroundColor: _gradientBottom,
      body: Stack(
        children: [
          // 1. BACKGROUND: TOP HALF (Solid White)
          // Occupies exactly 52% of the screen height
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.52,
            child: const ColoredBox(color: Colors.white),
          ),

          // 2. BACKGROUND: BOTTOM HALF (Red Gradient)
          // Starts exactly where the white half ends and fills to the bottom
          Positioned(
            top: size.height * 0.52,
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [_gradientTop, _gradientBottom],
                ),
              ),
            ),
          ),

          // 3. FOREGROUND CONTENT
          // SafeArea ensures content doesn't render under the physical device notch/status bar
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Persistent Top Navigation Bar
                _buildTopNav(),

                // Expanded forces the scroll view to take up all remaining vertical space
                Expanded(
                  child: SingleChildScrollView(
                    // Dynamically renders Home, About, or Auth based on state
                    child: _buildCurrentView(size),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // NAVIGATION ROUTER
  // ==========================================
  /// Acts as a switchboard, returning the correct UI layout widget
  /// based on the `_currentView` state variable.
  Widget _buildCurrentView(Size size) {
    switch (_currentView) {
      case AppView.home:
        return _buildHomeLayout();
      case AppView.about:
        return _buildAboutLayout();
      case AppView.auth:
        // If Auth view is selected, check if we need the success screen or the form
        return _authState == AuthState.success
            ? _buildSuccessLayout(size)
            : _buildAuthLayout(size);
    }
  }

  // ==========================================
  // TOP NAVIGATION BAR
  // ==========================================
  Widget _buildTopNav() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      // Creates the grey-to-white-to-grey horizontal gradient matching the Figma design
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFFEBEBEB),
            Colors.white,
            Colors.white,
            Color(0xFFEBEBEB),
          ],
          stops: [0.0, 0.31, 0.59, 1.0], // Explicit color stop positions
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Nav Bar Brand Logo
          Image.asset('assets/images/nav_logo.png', height: 48),

          Row(
            children: [
              _navTextItem('Homepage', AppView.home),
              const SizedBox(width: 10),
              _navTextItem('About', AppView.about),
              const SizedBox(width: 10),
              // Sign in specifically targets the AppView.auth AND the AuthState.login
              _navTextItem(
                'Sign in',
                AppView.auth,
                specificAuth: AuthState.login,
              ),
              const SizedBox(width: 12),

              // Highlighted "Sign up" Call-to-Action Button
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _currentView = AppView.auth;
                    _authState = AuthState.signup;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _maroonDark,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 0,
                  ),
                  minimumSize: const Size(0, 36),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0, // Flat design to match Figma
                ),
                child: const Text(
                  'Sign up',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Helper to build interactive text links in the top navigation.
  /// Handles active state styling (red underline and bolder font).
  Widget _navTextItem(
    String text,
    AppView targetView, {
    AuthState? specificAuth,
  }) {
    // Determine if this specific link is the currently active view
    bool isActive = _currentView == targetView;
    if (specificAuth != null && _currentView == AppView.auth) {
      isActive = _authState == specificAuth;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentView = targetView;
          if (specificAuth != null) _authState = specificAuth;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        decoration: BoxDecoration(
          // Applies the maroon underline only if active
          border: isActive
              ? const Border(bottom: BorderSide(color: _maroon, width: 2.0))
              : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w900 : FontWeight.bold,
            color: isActive ? _maroon : Colors.black87,
          ),
        ),
      ),
    );
  }

  // ==========================================
  // LAYOUT: HOME PAGE
  // ==========================================
  Widget _buildHomeLayout() {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Column(
        children: const [
          Text(
            'Explore, Learn,\nand Enjoy',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: _maroon,
              height: 1.2,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'EUventure Interactive University\nExploration Platform',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: _maroon,
            ),
          ),
          SizedBox(
            height: 150,
          ), // Ensures scroll view has enough space over red background
        ],
      ),
    );
  }

  // ==========================================
  // LAYOUT: ABOUT PAGE
  // ==========================================
  Widget _buildAboutLayout() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      padding: const EdgeInsets.all(24),
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
      child: Column(
        children: [
          const Text(
            'About us',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: _maroon,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Lorem Ipsum is simply dummy text of the printing and typesetting industry...',
            textAlign: TextAlign.justify,
            style: TextStyle(fontSize: 12, color: _maroon, height: 1.5),
          ),
          const SizedBox(height: 32),
          const Text(
            'EUventure Logo',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: _maroon,
            ),
          ),
          const SizedBox(height: 16),
          Image.asset('assets/images/nav_logo.png', height: 80),
          const SizedBox(height: 16),
          const Text(
            'Lorem Ipsum is simply dummy text of the printing and typesetting industry...',
            textAlign: TextAlign.justify,
            style: TextStyle(fontSize: 12, color: _maroon, height: 1.5),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // LAYOUT: LOGIN & SIGNUP
  // ==========================================
  /// Builds the main authentication form (Login or Signup modes).
  Widget _buildAuthLayout(Size size) {
    final isLogin = _authState == AuthState.login;

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
            // By enforcing left/right constraints and negative top positioning,
            // the image is forced to span the screen. Using BoxFit.fitWidth ensures
            // it scales proportionally without squishing, tucking behind the card below.
            Positioned(
              top: -112,
              left: 5,
              right: 5,
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.fitWidth,
              ),
            ),

            // LAYER 2 (FRONT): The Form Card
            Container(
              // Pushed down exactly 150px to allow the mascot to peek out the top
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
              child: _buildAuthCardContent(isLogin),
            ),
          ],
        ),
      ],
    );
  }

  // ==========================================
  // LAYOUT: SUCCESS SCREEN
  // ==========================================
  /// Renders the confirmation card shown after a successful registration.
  Widget _buildSuccessLayout(Size size) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 80),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            // LAYER 1 (BACK): Confirmation Card
            Container(
              margin: const EdgeInsets.only(
                top: 60,
                left: 32,
                right: 32,
                bottom: 40,
              ),
              padding: const EdgeInsets.fromLTRB(24, 70, 24, 32),
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
              child: Column(
                mainAxisSize: MainAxisSize
                    .min, // Hugs the contents tightly rather than expanding
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Account Created\nSuccessfully!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: _maroon,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'You can scan, learn, and enjoy\nwith EUventure',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _maroon,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Primary Confirm Button routes to the application Dashboard
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DashboardScreen(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _maroonDark,
                      side: const BorderSide(color: _maroonDark, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      minimumSize: const Size(0, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Confirm',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // LAYER 2 (FRONT): Small Mascot
            // Sits exactly at top: 0, straddling the top edge of the confirmation card
            Positioned(
              top: 0,
              child: Image.asset(
                'assets/images/logo.png',
                height: 120,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // CARD CONTENT BUILDER (Inputs & Buttons)
  // ==========================================
  /// The internal contents of the white authentication card.
  /// Dynamically inserts specific TextFields depending on the boolean [isLogin].
  Widget _buildAuthCardContent(bool isLogin) {
    final border = _border();

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

        // --- DYNAMIC INJECTION: SIGN UP FIELDS ---
        // The spread operator (...) unpacks these widgets into the Column
        // ONLY if the user is in Sign Up mode.
        if (!isLogin) ...[
          _buildTextField(
            controller: _fullNameController,
            hint: 'Fullname',
            border: border,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _studentIdController,
            hint: 'Student Id',
            border: border,
          ),
          const SizedBox(height: 12),
          _buildDropdownField(
            hint: 'Course/Program',
            items: _programs,
            selectedValue: _selectedProgram,
            border: border,
            onChanged: (v) => setState(() => _selectedProgram = v),
          ),
          const SizedBox(height: 12),
          _buildDropdownField(
            hint: 'Specialization',
            items: _specializations,
            selectedValue: _selectedSpecialization,
            border: border,
            onChanged: (v) => setState(() => _selectedSpecialization = v),
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _signupPasswordController,
            hint: 'Strong Password',
            border: border,
            obscureText: true,
          ),
          const SizedBox(height: 24),
        ],

        // --- DYNAMIC INJECTION: LOGIN FIELDS ---
        if (isLogin) ...[
          _buildTextField(
            controller: _emailController,
            hint: 'Email',
            icon: Icons.email_outlined,
            border: border,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _loginPasswordController,
            hint: 'Password',
            icon: Icons.lock_outline,
            border: border,
            obscureText: true,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize
                    .shrinkWrap, // Reduces invisible touch padding
              ),
              child: const Text(
                'Forgot password?',
                style: TextStyle(color: _maroon, fontSize: 10),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],

        // --- MAIN ACTION BUTTON ---
        ElevatedButton(
          onPressed: () {
            // TODO: Add the Backend JWT integration logic here
            if (isLogin) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const DashboardScreen()),
              );
            } else {
              // Proceed to confirmation screen upon clicking register
              setState(() => _authState = AuthState.success);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7A1D1D),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            minimumSize: const Size.fromHeight(45),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
          child: Text(
            isLogin ? 'Continue' : 'Confirm',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // REUSABLE INPUT WIDGETS
  // ==========================================
  /// Standardized TextField builder to enforce uniform styling and padding
  /// across the application without writing boilerplate code.
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required OutlineInputBorder border,
    IconData? icon,
    bool obscureText = false, // True for password fields to hide characters
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(fontSize: 14, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
        prefixIcon: icon != null
            ? Icon(icon, size: 20, color: Colors.grey.shade400)
            : null,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: const BorderSide(color: _maroon, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  /// Standardized Dropdown builder.
  /// Used to restrict user input to predefined lists (e.g., specific university programs)
  /// and soon this will be populated with the data from the data base
  Widget _buildDropdownField({
    required String hint,
    required List<String> items,
    required String? selectedValue,
    required OutlineInputBorder border,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      icon: Icon(
        Icons.keyboard_arrow_down,
        color: Colors.grey.shade400,
      ), // Custom chevron to match Figma
      style: const TextStyle(fontSize: 14, color: Colors.black87),
      dropdownColor: Colors.white,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: const BorderSide(color: _maroon, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      items: items
          .map(
            (v) => DropdownMenuItem(
              value: v,
              child: Text(v, style: const TextStyle(fontSize: 12)),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}
