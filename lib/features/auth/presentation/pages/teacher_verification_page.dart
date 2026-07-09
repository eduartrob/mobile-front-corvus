import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:mobile/shared/widgets/corvus_input_completed.dart';
import 'package:mobile/shared/widgets/corvus_button.dart';
import 'package:mobile/shared/widgets/auth_layout.dart';
import 'package:mobile/core/services/security_service.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';

class TeacherVerificationPage extends StatefulWidget {
  const TeacherVerificationPage({super.key});

  @override
  State<TeacherVerificationPage> createState() => _TeacherVerificationPageState();
}

class _TeacherVerificationPageState extends State<TeacherVerificationPage> {
  final SecurityService _securityService = SecurityService();
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _securityService.preventScreenshots(true);
  }

  @override
  void dispose() {
    _securityService.preventScreenshots(false);
    _codeController.dispose();
    super.dispose();
  }

  void _validateCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(() => _errorText = 'Por favor ingresa el código');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.validateUniversityCode(code);

    setState(() {
      _isLoading = false;
    });

    if (success) {
      if (mounted) {
        context.pushReplacement('/prof-dash');
      }
    } else {
      setState(() {
        _errorText = authProvider.errorMessage ?? 'Código inválido';
      });
    }
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
                  InputCompleted(
                    label: "Código de Verificación",
                    hint: "Ej. A7B2X9",
                    icon: Icons.vpn_key,
                    iconColor: Colors.deepPurple,
                    controller: _codeController,
                  ),
                  if (_errorText != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, left: 16.0),
                      child: Text(
                        _errorText!,
                        style: TextStyle(color: colors.error, fontSize: 12),
                      ),
                    ),
                  const SizedBox(height: 32),
                  
                  CorvusButton(
                    text: _isLoading ? "Validando..." : "Verificar y Continuar",
                    onPressed: _isLoading ? () {} : () {
                      FocusScope.of(context).unfocus();
                      _validateCode();
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
