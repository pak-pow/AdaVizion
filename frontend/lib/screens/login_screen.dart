import 'package:flutter/material.dart';
import 'dashboard_screen.dart';

enum AppView { home, about, auth }

enum AuthState { login, signup, success }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  AppView _currentView = AppView.auth;
  AuthState _authState = AuthState.login;

  final _emailController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  final _fullNameController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _signupPasswordController = TextEditingController();

  String? _selectedProgram;
  String? _selectedSpecialization;

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

  // --- Brand Colors ---
  static const _maroon = Color(0xFF7A1D1D);
  static const _maroonDark = Color(0xFF5D1414);
  static const _gradientTop = Color(0xFFB72424);
  static const _gradientBottom = Color(0xFF5D1414);

  @override
  void dispose() {
    _emailController.dispose();
    _loginPasswordController.dispose();
    _fullNameController.dispose();
    _studentIdController.dispose();
    _signupPasswordController.dispose();
    super.dispose();
  }

  OutlineInputBorder _border() => OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: Colors.grey.shade300),
  );

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _gradientBottom,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.52,
            child: const ColoredBox(color: Colors.white),
          ),

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

          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildTopNav(),
                Expanded(
                  child: SingleChildScrollView(child: _buildCurrentView(size)),
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
  Widget _buildCurrentView(Size size) {
    switch (_currentView) {
      case AppView.home:
        return _buildHomeLayout();
      case AppView.about:
        return _buildAboutLayout();
      case AppView.auth:
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
          stops: [0.0, 0.31, 0.59, 1.0],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset('assets/images/nav_logo.png', height: 48),

          Row(
            children: [
              _navTextItem('Homepage', AppView.home),
              const SizedBox(width: 10),
              _navTextItem('About', AppView.about),
              const SizedBox(width: 10),
              _navTextItem(
                'Sign in',
                AppView.auth,
                specificAuth: AuthState.login,
              ),
              const SizedBox(width: 12),

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
                  elevation: 0,
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

  Widget _navTextItem(
    String text,
    AppView targetView, {
    AuthState? specificAuth,
  }) {
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
          SizedBox(height: 150),
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
            'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s...',
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
  Widget _buildAuthLayout(Size size) {
    final isLogin = _authState == AuthState.login;

    return Column(
      children: [
        const SizedBox(height: 24),

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

        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Positioned(
              top: -112,
              left: 5,
              right: 5,
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.fitWidth,
              ),
            ),

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
  Widget _buildSuccessLayout(Size size) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 80),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
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
                mainAxisSize: MainAxisSize.min,
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

        ElevatedButton(
          onPressed: () {
            if (isLogin) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const DashboardScreen()),
              );
            } else {
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
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required OutlineInputBorder border,
    IconData? icon,
    bool obscureText = false,
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

  Widget _buildDropdownField({
    required String hint,
    required List<String> items,
    required String? selectedValue,
    required OutlineInputBorder border,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade400),
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
