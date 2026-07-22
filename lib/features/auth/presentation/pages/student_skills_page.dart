import 'package:mobile/core/network/api_endpoints.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/shared/widgets/corvus_button.dart';
import 'package:mobile/core/network/api_config.dart';
import 'package:mobile/core/network/auth_interceptor_client.dart';
import 'package:mobile/features/auth/presentation/provider/registration_provider.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile/core/services/security_service.dart';
import 'package:mobile/shared/widgets/auth_scaffold.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/core/error/error_handler.dart';
import 'package:mobile/core/error/app_exception.dart';
import 'package:mobile/core/di/di.dart';
import 'package:mobile/core/network/auth_interceptor_client.dart';

class StudentSkillsPage extends StatefulWidget {
  final List<String> suggestedSkills;

  const StudentSkillsPage({
    super.key,
    required this.suggestedSkills,
  });

  @override
  State<StudentSkillsPage> createState() => _StudentSkillsPageState();
}

class _StudentSkillsPageState extends State<StudentSkillsPage> {
  final SecurityService _securityService = SecurityService();
  final List<String> _selectedSkills = [];
  late List<String> _displaySkills;

  @override
  void dispose() {
    _securityService.preventScreenshots(false);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _securityService.preventScreenshots(true);
    if (widget.suggestedSkills.isNotEmpty) {
      final Set<String> uniqueSkills = Set.from(widget.suggestedSkills);
      _displaySkills = uniqueSkills.toList();
    } else {
      _displaySkills = [];
    }
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<RegistrationProvider>(context, listen: false);
      if (provider.selectedSkills.isNotEmpty) {
        setState(() {
          _selectedSkills.addAll(provider.selectedSkills);
        });
      }
    });
  }

  void _toggleSkill(String skill) async {
    await Future.delayed(const Duration(milliseconds: 150));
    
    if (!mounted) return;

    setState(() {
      if (_selectedSkills.contains(skill)) {
        _selectedSkills.remove(skill);
      } else {
        if (_selectedSkills.length < 10) {
          _selectedSkills.add(skill);
        } else {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.maxSkillsSelected)),
          );
        }
      }
    });
    
    Provider.of<RegistrationProvider>(context, listen: false).setSkills(_selectedSkills);
  }

  Widget _buildSkillChip(String skill, bool isSelected, ColorScheme colors, bool isDark) {
    return Material(
      color: isSelected
          ? colors.primary.withValues(alpha: 0.15)
          : (isDark ? colors.surfaceContainer : Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: isSelected
              ? Colors.transparent
              : (isDark
                  ? colors.outlineVariant.withValues(alpha: 0.3)
                  : const Color(0xFFE2E8F0)),
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: () => _toggleSkill(skill),
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSelected) ...[
                Icon(Icons.check, size: 16, color: colors.primary),
                const SizedBox(width: 6),
              ],
              Text(
                skill,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? colors.primary : colors.onSurfaceVariant,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isLoading = false;

  Future<void> _submitProfile() async {
    if (_selectedSkills.isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.selectAtLeastOneSkill)),
      );
      return;
    }

    setState(() => _isLoading = true);

    final provider = Provider.of<RegistrationProvider>(context, listen: false);
    
    try {
      final Map<String, dynamic> bodyData = {
        'email': provider.email,
        'password': provider.password,
        'roleName': provider.role.toUpperCase() == 'DOCENTE' ? 'PROFESOR' : provider.role.toUpperCase(),
      };
      if (provider.googleAuthCode != null) {
        bodyData['googleEmail'] = provider.email;
      }

      final registerResponse = await http.post(
        Uri.parse('${ApiConfig.apiGatewayUrl}${ApiEndpoints.authRegister}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(bodyData),
      );

      if (registerResponse.statusCode != 201 && registerResponse.statusCode != 200) {
        if (registerResponse.statusCode == 400) {
          final errData = json.decode(registerResponse.body);
          if (errData['error'] == 'User already exists') {
            throw Exception('Esta cuenta ya existe. Por favor retrocede e inicia sesión.');
          } else {
            final errorVal = errData['error'];
            if (errorVal is List) {
              final msgs = errorVal.map((e) => e['message']).join(', ');
              throw Exception('Error de validación: $msgs');
            } else if (errorVal != null) {
              throw Exception('Error de validación: $errorVal');
            } else {
              throw Exception('Error de validación: ${registerResponse.body}');
            }
          }
        } else {
          throw Exception('Error del servidor: ${registerResponse.statusCode}');
        }
      }

      final loginResponse = await http.post(
        Uri.parse('${ApiConfig.apiGatewayUrl}${ApiEndpoints.authLogin}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': provider.email, 'password': provider.password}),
      );

      if (loginResponse.statusCode != 200) {
        if (loginResponse.statusCode == 401) {
          throw Exception('El correo ya está registrado con una contraseña diferente.');
        }
        throw Exception('Error al iniciar sesión: credenciales inválidas');
      }

      final loginData = json.decode(loginResponse.body);
      if (loginData['token'] != null) {
        const storage = FlutterSecureStorage();
        await storage.write(key: 'auth_token', value: loginData['token']);
        if (loginData['user'] != null) {
          await storage.write(key: 'auth_id', value: loginData['user']['id']);
          await storage.write(key: 'auth_role', value: loginData['user']['role']);
        }
      } else {
        throw Exception('Error: No se recibió token en el login');
      }

      final response = await sl<AuthInterceptorClient>().put(
        Uri.parse('${ApiConfig.apiGatewayUrl}${ApiEndpoints.authCompleteProfile}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'full_name': provider.fullName,
          'enrollment_id': provider.matricula,
          'university_id': provider.universityId.isNotEmpty ? provider.universityId : provider.universityName,
          'career_id': provider.careerId.isNotEmpty ? provider.careerId : provider.careerName,
          'period_number': provider.periodNumber,
          'skills': _selectedSkills,
        }),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          await context.read<AuthProvider>().checkAuthStatus();
          context.pushReplacement('/inspiration');
        }
      } else {
        throw Exception('Error al guardar tu perfil: ${response.body}');
      }
    } catch (e) {
      debugPrint("Error saving profile: $e");
      if (mounted) {
        String errorMessage = e.toString();
        if (errorMessage.startsWith('Exception: ')) {
          errorMessage = errorMessage.substring(11);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return AuthScaffold(
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: colors.onSurface),
        onPressed: () {
          Provider.of<RegistrationProvider>(context, listen: false).setSkills(_selectedSkills);
          context.pop();
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.selectYourSkills,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colors.onSurface),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Center(
            child: Container(
              height: 3,
              width: 36,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [colors.primary, colors.tertiary]),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.chooseSkillsSubtitle(_selectedSkills.length.toString(), '10'),
            style: TextStyle(fontSize: 14, color: colors.onSurfaceVariant, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          AnimatedSize(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 500),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (_selectedSkills.isNotEmpty) ...[
                      Wrap(
                        spacing: 6,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: _selectedSkills.map((skill) => _buildSkillChip(skill, true, colors, isDark)).toList(),
                      ),
                      const SizedBox(height: 24),
                    ],
                    Wrap(
                      spacing: 6,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: _displaySkills
                          .where((s) => !_selectedSkills.contains(s))
                          .map((skill) => _buildSkillChip(skill, false, colors, isDark))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Spacer(),
          CorvusButton(
            text: _isLoading ? l10n.saving : l10n.finish,
            onPressed: _isLoading ? () {} : _submitProfile,
          ),
        ],
      ),
    );
  }
}