import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/shared/widgets/corvus_input_completed.dart';
import 'package:mobile/shared/widgets/corvus_button.dart';
import 'package:mobile/shared/widgets/auth_layout.dart';
import 'package:mobile/core/services/security_service.dart';

class TeacherVerificationPage extends StatefulWidget {
  const TeacherVerificationPage({super.key});

  @override
  State<TeacherVerificationPage> createState() => _TeacherVerificationPageState();
}

class _TeacherVerificationPageState extends State<TeacherVerificationPage> {
  final SecurityService _securityService = SecurityService();

  @override
  void initState() {
    super.initState();
    _securityService.preventScreenshots(true);
  }

  @override
  void dispose() {
    _securityService.preventScreenshots(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.onSurface),
          onPressed: () {
            context.pop();
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 
                         MediaQuery.of(context).padding.top - 
                         MediaQuery.of(context).padding.bottom,
            ),
            child: Center(
              child: AuthLayout(
                appTitle: 'Corvus',
                cardTitle: 'Verificación Docente',
                cardSubtitle: 'Ingresa el código de verificación que tu universidad te ha proporcionado para validar tu rol como docente.',
                children: [
                  const InputCompleted(
                    label: "Código de Verificación",
                    hint: "Ej. UNV-2026-X89",
                    icon: Icons.vpn_key,
                    iconColor: Colors.deepPurple,
                  ),
                  const SizedBox(height: 32),
                  
                  CorvusButton(
                    text: "Verificar y Continuar",
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      // Validar código. Por ahora va a home (Dashboard de Docente)
                      context.pushReplacement('/prof-dash');
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
