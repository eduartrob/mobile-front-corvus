import 'package:flutter/material.dart';
import 'package:mobile/features/auth/presentation/pages/login_page.dart';
import 'package:mobile/features/auth/presentation/pages/register_page.dart';
import 'package:mobile/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:mobile/features/auth/presentation/pages/verifyIdentity_page.dart';
import 'package:mobile/features/student_home/presentation/pages/student_home_page.dart';
import 'package:mobile/features/inspiration/presentation/pages/inspiration_page.dart';

class AppRouter extends StatelessWidget {
  final ThemeData? appTheme;
  final String initialRoute;

  const AppRouter({super.key, this.appTheme, this.initialRoute = '/'});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Corvus',
      theme: appTheme ?? ThemeData.light(),
      initialRoute: initialRoute,
      routes: {
        '/': (ctx) => const LoginPage(),
        '/register': (ctx) => const RegisterPage(),
        '/forgot-password': (ctx) => const ForgotPasswordPage(),
        '/verify-identity': (ctx) => const VerifyidentityPage(),
        '/home-student': (ctx) => const StudentHomePage(),
        '/inspiration': (ctx) => const InspirationPage(),
      },
    );
  }
}