import 'package:flutter/material.dart';
import 'package:mobile/src/plugin/organism/verifyIdentityOrg.dart';

class VerifyidentityPage extends StatelessWidget {
  const VerifyidentityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final String email = ModalRoute.of(context)?.settings.arguments as String? ?? 'u***@example.com';
    return VerifyIdentityOrg(email: email);
  }
}