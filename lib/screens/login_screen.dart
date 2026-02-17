import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void login() {
    String studentId = _idController.text;
    String password = _passwordController.text;

    if (studentId == "2023-1234" && password == "password") {
      print("LOGIN SUCCESS");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Welcome Back, Student!")));
    } else {
      print("LOGIN FAILED");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("INVALID ID or PASSWORD"),
          backgroundColor: Colors.red,
        ),
      );
    }
    ;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.school, size: 80, color: Colors.red),
            const SizedBox(height: 20),

            const Text(
              "ADAVIZION",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
