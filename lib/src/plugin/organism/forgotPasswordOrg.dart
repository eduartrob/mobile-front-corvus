import 'package:flutter/material.dart';
import 'package:mobile/src/plugin/molecule/forgotPasswordForm.dart';

class ForgotPasswordOrg extends StatelessWidget {
  const ForgotPasswordOrg({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1020),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF121827),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const ForgotPasswordForm(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
