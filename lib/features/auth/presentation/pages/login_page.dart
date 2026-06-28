import 'package:flutter/material.dart';
import 'package:mobile/features/auth/presentation/widgets/login_form.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF090E1A) : const Color(0xFFF1F5F9),
      body: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 
                           MediaQuery.of(context).padding.top - 
                           MediaQuery.of(context).padding.bottom,
              ),
              child: const Center(
                child: LoginForm(),
              ),
            ),
          ),
        ),
    );
  }
}
