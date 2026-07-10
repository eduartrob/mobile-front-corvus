import 'package:flutter/material.dart';
import 'package:mobile/features/auth/presentation/widgets/login_form.dart';
import 'package:mobile/core/services/security_service.dart';

class LoginPage extends StatefulWidget {
  final String role;
  
  const LoginPage({super.key, this.role = 'ALUMNO'});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final SecurityService _securityService = SecurityService();
  late String _currentRole;

  @override
  void initState() {
    super.initState();
    _currentRole = widget.role;
    _securityService.preventScreenshots(true);
  }

  @override
  void dispose() {
    _securityService.preventScreenshots(false);
    super.dispose();
  }

  void _handleRoleChanged(String newRole) {
    setState(() {
      _currentRole = newRole;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 
                           MediaQuery.of(context).padding.top - 
                           MediaQuery.of(context).padding.bottom,
              ),
              child: Center(
                child: LoginForm(
                  role: _currentRole,
                  onRoleChanged: _handleRoleChanged,
                ),
              ),
            ),
          ),
        ),
    );
  }
}
