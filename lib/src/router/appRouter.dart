import 'package:flutter/material.dart';
import 'package:mobile/src/page/login_page.dart';
import 'package:mobile/src/page/register_page.dart';
import 'package:mobile/src/page/forgot_password_page.dart';
import 'package:mobile/src/page/verifyIdentity_page.dart';

class AppRouter extends StatelessWidget {
  final ThemeData? appTheme;

  const AppRouter({super.key, this.appTheme});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Corvus',
      theme: appTheme ?? ThemeData.light(),
      initialRoute: '/',
      routes: {
        '/': (ctx) => const LoginPage(),
        '/register': (ctx) => const RegisterPage(),
        '/forgot-password': (ctx) => const ForgotPasswordPage(),
        '/verify-identity': (ctx) => const VerifyidentityPage(),
        '/home': (ctx) => const Scaffold(
              body: Center(child: Text('Home')),
            ),
      },
    );
  }
}