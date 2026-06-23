import 'package:flutter/material.dart';
import 'package:mobile/src/page/login_page.dart';

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
        '/home': (ctx) => const Scaffold(
              body: Center(child: Text('Home')),
            ),
      },
    );
  }
}