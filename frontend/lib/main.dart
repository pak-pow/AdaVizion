import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const AdaVisionApp());
}

class AdaVisionApp extends StatelessWidget {
  const AdaVisionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AdaVizion',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.red,
        useMaterial3: true,
      ),
      home: const AuthScreen(),
    );
  }
}
