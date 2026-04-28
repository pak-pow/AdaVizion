import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'services/api/api_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final token = await ApiConfig.getToken();
  
  runApp(AdaVisionApp(initialRoute: token != null ? '/dashboard' : '/login'));
}

class AdaVisionApp extends StatelessWidget {
  final String initialRoute;
  const AdaVisionApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AdaVizion',
      navigatorKey: ApiConfig.navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.red,
        useMaterial3: true,
      ),
      initialRoute: initialRoute,
      routes: {
        '/login': (context) => const AuthScreen(),
        '/dashboard': (context) => const DashboardScreen(),
      },
    );
  }
}
