import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/shared/widgets/corvus_input_completed.dart';
import 'package:mobile/shared/widgets/corvus_button.dart';
import 'package:mobile/shared/widgets/auth_scaffold.dart';
import 'package:mobile/core/services/security_service.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';
import 'package:provider/provider.dart';

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
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _securityService.preventScreenshots(true);
    _codeController.addListener(_onCodeChanged);
  }

  @override
  void dispose() {
    _securityService.preventScreenshots(false);
    _codeController.removeListener(_onCodeChanged);
    _codeController.dispose();
    super.dispose();
  }

  void _onCodeChanged() {
    final text = _codeController.text;
    if (text.length > 8 || text.contains(RegExp(r'[^a-zA-Z0-9-]'))) {
      if (_validationError == null) {
        setState(() {
          _validationError = 'Los códigos de verificación constan de 5-8 caracteres formados por letras y números, y sin espacios ni símbolos.';
        });
      }
    } else {
      if (_validationError != null) {
        setState(() {
          _validationError = null;
        });
      }
    }
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
        context.push('/register-teacher-info');
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

    return AuthScaffold(
      role: 'DOCENTE',
      bottomAlign: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: colors.onSurface),
        onPressed: () => context.pop(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Verificación Docente',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Center(
            child: Container(
              height: 3,
              width: 36,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colors.primary, colors.tertiary],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ingresa el código de verificación que tu universidad te ha proporcionado para validar tu rol como docente.',
            style: TextStyle(
              fontSize: 14,
              color: colors.onSurfaceVariant,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          InputCompleted(
            label: "Código de Verificación",
            hint: "Ej. A7B2X9",
            icon: Icons.vpn_key,
            iconColor: colors.primary,
            controller: _codeController,
            errorText: _validationError ?? _errorText,
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
    );
  }
}

