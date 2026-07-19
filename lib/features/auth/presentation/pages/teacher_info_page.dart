import 'package:mobile/core/network/api_endpoints.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/core/network/api_config.dart';
import 'package:mobile/shared/widgets/auth_scaffold.dart';
import 'package:mobile/shared/widgets/corvus_input_completed.dart';
import 'package:mobile/shared/widgets/corvus_button.dart';
import 'package:mobile/features/auth/presentation/provider/registration_provider.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';
import 'package:mobile/features/auth/presentation/widgets/career_autocomplete_field.dart';
import 'package:mobile/core/services/security_service.dart';

class TeacherInfoPage extends StatefulWidget {
  const TeacherInfoPage({super.key});

  @override
  State<TeacherInfoPage> createState() => _TeacherInfoPageState();
}

class _TeacherInfoPageState extends State<TeacherInfoPage> {
  final SecurityService _securityService = SecurityService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _careerSearchController = TextEditingController();
  final TextEditingController _universityIdController = TextEditingController();
  
  String? _universityName;
  String? _universityId;
  bool _isLoading = false;
  
  final List<String> _selectedCareers = [];

  @override
  void initState() {
    super.initState();
    _securityService.preventScreenshots(true);
    _loadUniversityData();
  }

  Future<void> _loadUniversityData() async {
    const storage = FlutterSecureStorage();
    final uid = await storage.read(key: 'auth_university_id');
    final uname = await storage.read(key: 'auth_university_name');
    
    if (mounted) {
      setState(() {
        _universityId = uid;
        _universityName = uname;
        _universityIdController.text = uid ?? ''; // Utilizado internamente por el autocomplete para filtrar
      });
    }
  }

  @override
  void dispose() {
    _securityService.preventScreenshots(false);
    _nameController.dispose();
    _careerSearchController.dispose();
    _universityIdController.dispose();
    super.dispose();
  }

  void _addCareer(String career) {
    if (career.trim().isEmpty) return;
    if (!_selectedCareers.contains(career.trim())) {
      setState(() {
        _selectedCareers.add(career.trim());
      });
    }
    _careerSearchController.clear();
  }

  void _removeCareer(String career) {
    setState(() {
      _selectedCareers.remove(career);
    });
  }

  Future<void> _submitProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa tu nombre completo')),
      );
      return;
    }

    if (_selectedCareers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona al menos una carrera')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final provider = Provider.of<RegistrationProvider>(context, listen: false);
    
    try {
      // 1. Registro
      final Map<String, dynamic> bodyData = {
        'email': provider.email,
        'password': provider.password,
        'roleName': provider.role.toUpperCase() == 'DOCENTE' ? 'PROFESOR' : provider.role.toUpperCase(),
        'fullName': _nameController.text.trim(),
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
          throw Exception('Error del servidor al registrar');
        }
      }

      // 2. Login
      final loginResponse = await http.post(
        Uri.parse('${ApiConfig.apiGatewayUrl}${ApiEndpoints.authLogin}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': provider.email,
          'password': provider.password,
        }),
      );

      if (loginResponse.statusCode != 200) {
        throw Exception('Error al iniciar sesión automáticamente');
      }

      final loginData = json.decode(loginResponse.body);
      const storage = FlutterSecureStorage();
      
      if (loginData['token'] != null) {
        await storage.write(key: 'auth_token', value: loginData['token']);
        if (loginData['user'] != null) {
          await storage.write(key: 'auth_id', value: loginData['user']['id']);
          await storage.write(key: 'auth_role', value: loginData['user']['role']);
        }
      } else {
        throw Exception('Error: No se recibió token en el login');
      }

      // 3. Completar perfil con universidad y carrera
      // Enviamos la primera carrera como career_id y las demás como tags/skills 
      // (el backend las guardará como pueda según la limitación de 1 carrera por usuario).
      final responseProfile = await http.put(
        Uri.parse('${ApiConfig.apiGatewayUrl}${ApiEndpoints.authCompleteProfile}'), 
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${loginData['token']}'
        },
        body: json.encode({
          'full_name': _nameController.text.trim(),
          'university_id': _universityId,
          'career_id': _selectedCareers.first,
          'skills': _selectedCareers.length > 1 ? _selectedCareers.skip(1).toList() : [],
        }),
      );

      if (responseProfile.statusCode != 200) {
        debugPrint('Warning: Could not link university to teacher profile fully');
      }

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        await context.read<AuthProvider>().checkAuthStatus();
        context.pushReplacement('/prof-dash');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AuthScaffold(
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: colors.onSurface),
        onPressed: () => context.pop(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Tus Datos',
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
            'Comencemos a personalizar tu perfil docente en Corvus.',
            style: TextStyle(
              fontSize: 14,
              color: colors.onSurfaceVariant,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
                if (_universityName != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark ? colors.surfaceContainer : colors.primaryContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.account_balance, color: colors.primary, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Universidad Validada',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _universityName!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: colors.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.check_circle, color: Colors.green.shade400, size: 20),
                        ],
                      ),
                    ),
                  ),
                
                InputCompleted(
                  label: "Nombre completo",
                  hint: "Ej. Juan Pérez García",
                  icon: Icons.person,
                  controller: _nameController,
                  iconColor: Colors.blueAccent,
                ),
                const SizedBox(height: 16),
                
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Carreras que impartes",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                CareerAutocompleteField(
                  controller: _careerSearchController,
                  universityController: _universityIdController,
                  isDark: isDark,
                  colors: colors,
                  onSelected: (selection) {
                    _addCareer(selection);
                  },
                ),
                const SizedBox(height: 12),
                
                if (_selectedCareers.isNotEmpty)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: _selectedCareers.map((career) {
                        return Chip(
                          label: Text(career),
                          labelStyle: TextStyle(
                            fontSize: 12,
                            color: colors.onSecondaryContainer,
                          ),
                          backgroundColor: colors.secondaryContainer,
                          deleteIcon: Icon(
                            Icons.close,
                            size: 16,
                            color: colors.onSecondaryContainer,
                          ),
                          onDeleted: () => _removeCareer(career),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide.none,
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                const SizedBox(height: 32),
                CorvusButton(
                  text: _isLoading ? "Guardando..." : "Finalizar Registro",
                  onPressed: _isLoading ? () {} : _submitProfile,
                ),
              ],
            ),
          );
  }
}