import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // This boolean controls which form we are showing
  bool _isLoginMode = true;

  // Controllers to grab the text the user types
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // new signupControllers
  final _nameController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _programController = TextEditingController();
  final _yearLevelController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _studentIdController.dispose();
    _programController.dispose();
    _yearLevelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Colors.grey.shade300),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF5D1414),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.55, // Top 55% is white
            child: Container(color: Colors.white),
          ),

          Positioned(
            top: size.height * 0.55, 
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFB72424), Color(0xFF5D1414)],
                ),
              ),
            ),
          ),

          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 30),

                  // The EUventure Title Image
                  Image.asset('assets/images/title.png', height: 90),

                  // The Mascot & Card Stack
                  Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 0),
                        child: Image.asset(
                          'assets/images/logo.png',
                          height:
                              400, // Nice and large, matching Figma proportions
                          fit: BoxFit.contain,
                        ),
                      ),

                      Container(
                        margin: const EdgeInsets.only(
                          top: 170,
                          left: 24,
                          right: 24,
                          bottom: 40,
                        ),
                        padding: const EdgeInsets.only(
                          top: 32,
                          left: 24,
                          right: 24,
                          bottom: 24,
                        ),
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
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              _isLoginMode ? 'Sign in' : 'Sign up',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF7A1D1D),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'to explore and learn in Enverga\nUniversity',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF7A1D1D),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 30),
                            if (!_isLoginMode) ...[
                              TextField(
                                controller: _studentIdController,
                                decoration: InputDecoration(
                                  labelText: 'Student Number',
                                  prefixIcon: const Icon(
                                    Icons.badge_outlined,
                                    size: 20,
                                  ),
                                  enabledBorder: inputBorder,
                                  focusedBorder: inputBorder,
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  labelText: 'Full Name',
                                  prefixIcon: const Icon(
                                    Icons.person_outline,
                                    size: 20,
                                  ),
                                  enabledBorder: inputBorder,
                                  focusedBorder: inputBorder,
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _programController,
                                decoration: InputDecoration(
                                  labelText: 'Program (e.g., BSCS)',
                                  prefixIcon: const Icon(
                                    Icons.school_outlined,
                                    size: 20,
                                  ),
                                  enabledBorder: inputBorder,
                                  focusedBorder: inputBorder,
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _yearLevelController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Year Level (1-4)',
                                  prefixIcon: const Icon(
                                    Icons.format_list_numbered,
                                    size: 20,
                                  ),
                                  enabledBorder: inputBorder,
                                  focusedBorder: inputBorder,
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Email Field
                            TextField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                labelStyle: const TextStyle(fontSize: 14),
                                prefixIcon: const Icon(
                                  Icons.email_outlined,
                                  size: 20,
                                ),
                                enabledBorder: inputBorder,
                                focusedBorder: inputBorder,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Password Field
                            TextField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                labelStyle: const TextStyle(fontSize: 14),
                                prefixIcon: const Icon(
                                  Icons.lock_outline,
                                  size: 20,
                                ),
                                enabledBorder: inputBorder,
                                focusedBorder: inputBorder,
                              ),
                            ),

                            if (_isLoginMode)
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {},
                                  child: const Text(
                                    'Forgot password?',
                                    style: TextStyle(
                                      color: Color(0xFF7A1D1D),
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              )
                            else
                              const SizedBox(height: 24),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8B1A1A),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              onPressed: () {
                                print('Email: ${_emailController.text}');
                              },
                              child: const Text(
                                'Continue',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isLoginMode = !_isLoginMode;
                                });
                              },
                              child: Text(
                                _isLoginMode
                                    ? 'Don\'t have an account? Sign up'
                                    : 'Already have an account? Sign in',
                                style: const TextStyle(
                                  color: Color(0xFF7A1D1D),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
