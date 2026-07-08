import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/theme/app_dimens.dart';
import 'package:mobile/shared/widgets/corvus_button.dart';
import 'package:mobile/core/network/api_config.dart';
import 'package:mobile/core/network/auth_interceptor_client.dart';
import 'package:mobile/features/auth/presentation/provider/registration_provider.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
  final List<String> _selectedSkills = [];
  late List<String> _displaySkills;

  @override
  void initState() {
    super.initState();
    final List<String> allSkills = [
      'Resolución de problemas', 'Trabajo en equipo', 'Comunicación', 'Liderazgo', 'Pensamiento crítico', 'Adaptabilidad', 'Organización', 'Creatividad',
      'Desarrollo Web', 'Desarrollo Móvil', 'Bases de Datos', 'Machine Learning', 'Inteligencia Artificial', 'Diseño UI/UX', 'Análisis de Datos', 'Gestión de Proyectos',
      'Marketing Digital', 'Ventas', 'Finanzas', 'Contabilidad', 'Recursos Humanos', 'Redes', 'Seguridad Informática', 'Cloud Computing',
      'Python', 'Java', 'JavaScript', 'TypeScript', 'C++', 'C#', 'PHP', 'Ruby', 'Swift', 'Kotlin', 'Dart', 'Go', 'Rust',
      'React', 'Angular', 'Vue.js', 'Node.js', 'Express', 'Django', 'Flask', 'Spring Boot', 'Laravel', 'ASP.NET',
      'SQL', 'NoSQL', 'MongoDB', 'PostgreSQL', 'MySQL', 'Firebase', 'AWS', 'Google Cloud', 'Azure', 'Docker', 'Kubernetes',
      'Git', 'Metodologías Ágiles', 'Scrum', 'Kanban', 'Inglés', 'Oratoria', 'Negociación', 'Empatía', 'Gestión del tiempo',
      'Edición de Video', 'Edición de Fotografía', 'Ilustración', 'Animación 3D', 'Copywriting', 'SEO', 'SEM',
      'Investigación', 'Redacción Académica', 'Estadística', 'Matemáticas', 'Física', 'Química', 'Biología', 'Medicina',
      'Derecho', 'Psicología', 'Sociología', 'Historia', 'Filosofía', 'Arte', 'Música', 'Idiomas',
      'Diseño Gráfico', 'Arquitectura', 'Ingeniería Civil', 'Ingeniería Mecánica', 'Ingeniería Eléctrica', 'Ingeniería Industrial',
      'Mecatrónica', 'Robótica', 'Electrónica', 'Telecomunicaciones', 'Automatización', 'Internet de las Cosas (IoT)'
    ];

    if (widget.suggestedSkills.isNotEmpty) {
      // Put suggested skills first, then append the rest without duplicates
      final Set<String> uniqueSkills = Set.from(widget.suggestedSkills);
      uniqueSkills.addAll(allSkills);
      _displaySkills = uniqueSkills.take(100).toList();
    } else {
      _displaySkills = allSkills.take(100).toList();
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
    // Add a slight delay so the user feels the ink ripple before the button moves
    await Future.delayed(const Duration(milliseconds: 150));
    
    if (!mounted) return;

    setState(() {
      if (_selectedSkills.contains(skill)) {
        _selectedSkills.remove(skill);
      } else {
        if (_selectedSkills.length < 10) {
          _selectedSkills.add(skill);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Puedes seleccionar un máximo de 10 habilidades'),
            ),
          );
        }
      }
    });
    
    // Save to provider on toggle
    Provider.of<RegistrationProvider>(context, listen: false).setSkills(_selectedSkills);
  }

  Widget _buildSkillChip(String skill, bool isSelected, ColorScheme colors, bool isDark) {
    return Material(
      color: isSelected
          ? colors.primary.withValues(alpha: 0.15)
          : (isDark ? colors.surfaceContainer : Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
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
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSelected) ...[
                Icon(
                  Icons.check,
                  size: 16,
                  color: colors.primary,
                ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos una habilidad')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final provider = Provider.of<RegistrationProvider>(context, listen: false);
    
    try {
      // 1. Primero registramos al usuario porque aún no tiene cuenta
      final registerResponse = await http.post(
        Uri.parse('${ApiConfig.apiGatewayUrl}/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': provider.email,
          'password': provider.password,
          'roleName': provider.role.toUpperCase(),
        }),
      );

      // Si falla el registro, revisamos el motivo
      if (registerResponse.statusCode != 201 && registerResponse.statusCode != 200) {
        if (registerResponse.statusCode == 400) {
          final errData = json.decode(registerResponse.body);
          if (errData['error'] == 'User already exists') {
            throw Exception('Esta cuenta ya existe. Por favor retrocede e inicia sesión.');
          } else {
            throw Exception('Error de validación: ${errData['error']}');
          }
        } else {
          throw Exception('Error del servidor: ${registerResponse.statusCode}');
        }
      }

      // 1.5. Hacemos login para obtener el token porque el registro no lo devuelve
      final loginResponse = await http.post(
        Uri.parse('${ApiConfig.apiGatewayUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': provider.email,
          'password': provider.password,
        }),
      );

      if (loginResponse.statusCode != 200) {
        if (loginResponse.statusCode == 401) {
          throw Exception('El correo ya está registrado con una contraseña diferente.');
        }
        throw Exception('Error al iniciar sesión: credenciales inválidas');
      }

      final loginData = json.decode(loginResponse.body);
      if (loginData['token'] != null) {
        // Guardar el token en almacenamiento seguro para que el apiClient lo use
        const storage = FlutterSecureStorage();
        await storage.write(key: 'auth_token', value: loginData['token']);
        
        if (loginData['user'] != null) {
          await storage.write(key: 'auth_id', value: loginData['user']['id']);
          await storage.write(key: 'auth_role', value: loginData['user']['role']);
        }
      } else {
        throw Exception('Error: No se recibió token en el login');
      }

      // 2. Completamos el perfil del estudiante
      final response = await apiClient.put(
        Uri.parse('${ApiConfig.apiGatewayUrl}/auth/complete-student-profile'),
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
          // Actualizar el estado global para que el router nos deje pasar
          await context.read<AuthProvider>().checkAuthStatus();
          context.pushReplacement('/inspiration');
        }
      } else {
        throw Exception('Error al guardar tu perfil: ${response.body}');
      }
    } catch (e) {
      debugPrint("Error saving profile: $e");
      if (mounted) {
        // Clean up the Exception: prefix if present
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
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.onSurface),
          onPressed: () {
            // Force save
            Provider.of<RegistrationProvider>(context, listen: false).setSkills(_selectedSkills);
            context.pop();
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.screenMargin,
              vertical: 24.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? colors.surfaceContainerHighest.withValues(alpha: 0.5)
                        : colors.primaryContainer.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SvgPicture.asset('assets/icons/logo.svg'),
                ),
                const SizedBox(height: 12),
                Text(
                  'Corvus',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                    letterSpacing: -1,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 8, bottom: 24),
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark ? colors.surface : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark
                          ? colors.outlineVariant.withValues(alpha: 0.2)
                          : const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                    boxShadow: isDark
                        ? [
                            BoxShadow(
                              color: const Color(
                                0xFF6366F1,
                              ).withValues(alpha: 0.22),
                              blurRadius: 50,
                              spreadRadius: 2,
                              offset: const Offset(0, 8),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: const Color(
                                0xFF3B82F6,
                              ).withValues(alpha: 0.18),
                              blurRadius: 40,
                              spreadRadius: 2,
                              offset: const Offset(0, 10),
                            ),
                          ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Selecciona tus habilidades',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: colors.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Elige hasta 10 habilidades que deseas obtener o mejorar en tu carrera. (${_selectedSkills.length}/10)',
                        style: TextStyle(
                          fontSize: 14,
                          color: colors.onSurfaceVariant,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      AnimatedSize(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutCubic,
                        child: Container(
                          constraints: const BoxConstraints(maxHeight: 350),
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                if (_selectedSkills.isNotEmpty) ...[
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    alignment: WrapAlignment.center,
                                    children: _selectedSkills.map((skill) {
                                      return _buildSkillChip(skill, true, colors, isDark);
                                    }).toList(),
                                  ),
                                  const SizedBox(height: 24),
                                ],
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  alignment: WrapAlignment.center,
                                  children: _displaySkills
                                      .where((s) => !_selectedSkills.contains(s))
                                      .map((skill) {
                                    return _buildSkillChip(skill, false, colors, isDark);
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
                      CorvusButton(
                        text: _isLoading ? "Guardando..." : "Finalizar",
                        onPressed: _isLoading ? () {} : _submitProfile,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
