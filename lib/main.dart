import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'welcome_page.dart';
import 'main_layout.dart';
import 'firebase_options.dart';
import 'auth/register_page.dart';
import 'auth/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }

  runApp(const SyifaLaundryApp());
}

class SyifaLaundryApp extends StatelessWidget {
  const SyifaLaundryApp({super.key});

  static const Color primaryColor = Color(0xFF86D5E0);
  static const Color accentColor = Color(0xFF63B9C4);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Syifa Laundry',
      theme: ThemeData(
        primaryColor: primaryColor,
        colorScheme: ColorScheme.fromSeed(seedColor: primaryColor).copyWith(
          secondary: accentColor,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      debugShowCheckedModeBanner: false,

      // 🔹 Tambahkan route di sini
      routes: {
        '/register': (context) => const RegisterPage(),
        '/main': (context) => const MainLayout(),
        '/login': (context) => const LoginPage(),
      },

      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            return const MainLayout();
          } else {
            return const WelcomePage();
          }
        },
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.idTokenChanges(),
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(
                color: SyifaLaundryApp.accentColor,
              ),
            ),
          );
        }

        // Jika sudah login
        if (snapshot.hasData) {
          return const MainLayout();
        }

        // Jika belum login
        return const WelcomePage();
      },
    );
  }
}
