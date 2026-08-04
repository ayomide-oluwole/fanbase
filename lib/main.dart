import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fanbase/services/auth_service.dart';
import 'package:fanbase/screens/home_screen.dart';
import 'package:fanbase/screens/auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Initialize Auth Service
  final AuthService authService = AuthService();
  
  // If no one is logged in, start an anonymous session for browsing
  if (authService.currentUser == null) {
    await authService.signInAnonymously();
  }

  runApp(const FanbaseApp());
}

class FanbaseApp extends StatelessWidget {
  const FanbaseApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fanbase',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          elevation: 0,
          centerTitle: false,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1E1E1E),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
      home: const HomeScreen(),
      // Define routes so we can easily navigate to Auth screens
      routes: {
        '/login': (context) => const AuthScreen(isLogin: true),
        '/signup': (context) => const AuthScreen(isLogin: false),
      },
    );
  }
}
