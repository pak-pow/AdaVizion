import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import '../services/api/auth_api.dart';
import 'auth/auth_enums.dart';
import 'auth/widgets/top_nav_bar.dart';
import 'auth/views/home_layout_view.dart';
import 'auth/views/about_layout_view.dart';
import 'auth/views/auth_layout_view.dart';
import 'auth/views/success_layout_view.dart';

// ============================================================================
// AUTH SCREEN (Shell)
//
// This file now contains only the top-level state machine:
//   - AppView / AuthState enums  → auth/auth_enums.dart
//   - AuthTopNavBar              → auth/widgets/top_nav_bar.dart
//   - HomeLayoutView             → auth/views/home_layout_view.dart
//   - AboutLayoutView            → auth/views/about_layout_view.dart
//   - AuthLayoutView             → auth/views/auth_layout_view.dart
//   - SuccessLayoutView          → auth/views/success_layout_view.dart
//   - AuthTextField / Dropdown   → auth/widgets/auth_text_field.dart
//
// This shell retains:
//   - All TextEditingControllers (owned here so login logic can access values)
//   - _isLoading and dropdown state
//   - AuthApi.login() / AuthApi.register() calls
//   - SnackBar helpers
//   - Navigation to DashboardScreen after login
// ============================================================================

// Re-export enums so external code (e.g. main.dart) continues to find
// AuthScreen in this file without any changes.
export 'auth/auth_enums.dart';

/// The main entry point for the unauthenticated user experience.
/// Handles routing between Home, About, and Auth screens within a
/// single page architecture.
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
  bool _isLoading = false;

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

  // ─── BRANDING COLORS ────────────────────────────────────────────────────────
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _gradientBottom,
      body: Stack(
        children: [
          // 1. BACKGROUND: TOP HALF (Solid White)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.52,
            child: const ColoredBox(color: Colors.white),
          ),

          // 2. BACKGROUND: BOTTOM HALF (Red Gradient)
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
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Persistent Top Navigation Bar
                AuthTopNavBar(
                  currentView: _currentView,
                  authState: _authState,
                  onNavigate: (view, {specificAuth}) {
                    setState(() {
                      _currentView = view;
                      if (specificAuth != null) _authState = specificAuth;
                    });
                  },
                ),

                Expanded(
                  child: SingleChildScrollView(
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

  // ─── NAVIGATION ROUTER ───────────────────────────────────────────────────────
  /// Acts as a switchboard, returning the correct UI layout widget
  /// based on the `_currentView` state variable.
  Widget _buildCurrentView(Size size) {
    switch (_currentView) {
      case AppView.home:
        return const HomeLayoutView();
      case AppView.about:
        return const AboutLayoutView();
      case AppView.auth:
        final isSuccess = _authState == AuthState.success;
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          switchInCurve: Curves.easeInOutCubic,
          switchOutCurve: Curves.easeInOutCubic,
          child: KeyedSubtree(
            key: ValueKey<bool>(isSuccess),
            child: isSuccess
                ? SuccessLayoutView(
                    onGoToLogin: () {
                      _showSuccessSnackBar(
                        'Registration successful! Please log in.',
                      );
                      setState(() => _authState = AuthState.login);
                    },
                  )
                : AuthLayoutView(
                    isLogin: _authState == AuthState.login,
                    isLoading: _isLoading,
                    emailController: _emailController,
                    loginPasswordController: _loginPasswordController,
                    fullNameController: _fullNameController,
                    studentIdController: _studentIdController,
                    signupPasswordController: _signupPasswordController,
                    selectedProgram: _selectedProgram,
                    selectedSpecialization: _selectedSpecialization,
                    onProgramChanged: (v) {
                      setState(() {
                        _selectedProgram = v;
                        _selectedSpecialization =
                            null; // Reset specialization if course changes
                      });
                    },
                    onSpecializationChanged: (v) =>
                        setState(() => _selectedSpecialization = v),
                    onSubmit: _handleSubmit,
                  ),
          ),
        );
    }
  }

  // ─── SUBMIT HANDLER ──────────────────────────────────────────────────────────
  /// Handles both login and registration form submission.
  Future<void> _handleSubmit() async {
    setState(() => _isLoading = true);
    final isLogin = _authState == AuthState.login;

    try {
      if (isLogin) {
        await AuthApi.login(
          _emailController.text.trim(),
          _loginPasswordController.text,
        );
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
          );
        }
      } else {
        final studentData = {
          'full_name': _fullNameController.text.trim(),
          'student_number': _studentIdController.text.trim(),
          'program': _selectedProgram,
          'specialization': _selectedSpecialization,
          'password': _signupPasswordController.text,
        };

        await AuthApi.register(studentData);

        if (mounted) {
          _showSuccessSnackBar('Account successfully created!');
          setState(() => _authState = AuthState.success);
        }
      }
    } catch (error) {
      if (mounted) {
        _showErrorSnackBar(
          error.toString().replaceAll('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── SNACKBAR HELPERS ────────────────────────────────────────────────────────
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
