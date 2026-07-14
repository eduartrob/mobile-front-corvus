import 'dart:convert';
import 'dart:math' as Math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/shared/widgets/corvus_input_completed.dart';
import 'package:mobile/shared/widgets/corvus_button.dart';
import 'package:mobile/shared/widgets/corvus_label.dart';
import 'package:mobile/core/network/api_config.dart';
import '../widgets/university_autocomplete_field.dart';
import '../widgets/career_autocomplete_field.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/features/auth/presentation/provider/registration_provider.dart';
import 'package:provider/provider.dart';
import 'package:mobile/shared/widgets/auth_layout.dart';
import 'package:mobile/core/services/security_service.dart';

class StudentUniversityPage extends StatefulWidget {
  const StudentUniversityPage({super.key});

  @override
  State<StudentUniversityPage> createState() => _StudentUniversityPageState();
}

class _StudentUniversityPageState extends State<StudentUniversityPage> {
  final SecurityService _securityService = SecurityService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _matriculaController = TextEditingController();
  final TextEditingController _universityController = TextEditingController();
  final TextEditingController _careerController = TextEditingController();
  final TextEditingController _periodNumberController = TextEditingController();

  String _selectedPeriod = 'Semestre';
  final List<String> _periodOptions = [
    'Semestre',
    'Cuatrimestre',
    'Trimestre',
    'Bimestre',
    'Anual',
    'Otro',
  ];

  bool _isLoading = false;
  String _lastQuery = '';
  
  String _selectedUniversityName = '';
  String _selectedCareerName = '';

  @override
  void dispose() {
    _securityService.preventScreenshots(false);
    _nameController.dispose();
    _matriculaController.dispose();
    _universityController.dispose();
    _careerController.dispose();
    _periodNumberController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _securityService.preventScreenshots(true);
    final provider = Provider.of<RegistrationProvider>(context, listen: false);
    
    if (provider.fullName.isNotEmpty) _nameController.text = provider.fullName;
    if (provider.matricula.isNotEmpty) _matriculaController.text = provider.matricula;
    if (provider.universityName.isNotEmpty) {
      _universityController.text = provider.universityName;
      _selectedUniversityName = provider.universityName;
    }
    if (provider.careerName.isNotEmpty) {
      _careerController.text = provider.careerName;
      _selectedCareerName = provider.careerName;
    }
    if (provider.periodNumber.isNotEmpty) _periodNumberController.text = provider.periodNumber;
    if (provider.periodName.isNotEmpty) {
      _selectedPeriod = provider.periodName;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nameController.addListener(() {
        provider.fullName = _nameController.text;
      });
      _matriculaController.addListener(() {
        provider.matricula = _matriculaController.text;
      });
      _universityController.addListener(() {
        provider.universityName = _universityController.text;
      });
      _careerController.addListener(() {
        provider.careerName = _careerController.text;
      });
      _periodNumberController.addListener(() {
        provider.periodNumber = _periodNumberController.text;
      });
    });
  }

  Future<void> _submitCareer() async {
    FocusScope.of(context).unfocus();
    final name = _nameController.text.trim();
    final matricula = _matriculaController.text.trim();
    final universityName = _universityController.text.trim();
    final careerName = _careerController.text.trim();

    if (name.isEmpty || matricula.isEmpty || universityName.isEmpty || careerName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa todos los campos requeridos')),
      );
      return;
    }

    if (_selectedUniversityName != universityName || _selectedUniversityName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona una universidad válida de la lista sugerida.')),
      );
      return;
    }

    if (_selectedCareerName != careerName || _selectedCareerName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona una carrera válida de la lista sugerida.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.apiGatewayUrl}/auth/careers/resolve'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'careerName': careerName}),
          )
          .timeout(const Duration(seconds: 40));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<String> skills = List<String>.from(data['skills']);
        
        final provider = Provider.of<RegistrationProvider>(context, listen: false);
        provider.setUniversityData(
          fullName: name,
          matricula: matricula,
          universityId: _universityController.text, // El backend lo resuelve usando el nombre si no es un UUID
          universityName: _universityController.text,
          periodName: _selectedPeriod,
          periodNumber: _periodNumberController.text.trim().isEmpty ? '1' : _periodNumberController.text.trim(),
          careerId: data['career']['id'],
          careerName: careerName,
        );

        if (mounted) {
          context.push('/register-student-skills', extra: {
            'skills': skills,
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al analizar la carrera')),
          );
        }
      }
    } catch (e) {
      debugPrint("Error resolving career: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ocurrió un error de conexión')),
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

    if (_isLoading) {
      return Scaffold(
        body: _buildShimmerLoading(colors, isDark),
      );
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: AuthLayout(
        appTitle: 'Corvus',
        cardTitle: 'Información institucional',
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.onSurface),
          onPressed: () {
            final provider = Provider.of<RegistrationProvider>(context, listen: false);
            provider.fullName = _nameController.text;
            provider.matricula = _matriculaController.text;
            provider.universityName = _universityController.text;
            provider.careerName = _careerController.text;
            provider.periodNumber = _periodNumberController.text;
            context.pop();
          },
        ),
        children: [
                    InputCompleted(
                      label: "Nombre completo",
                      hint: "Ej. Juan Pérez García",
                      icon: Icons.person,
                      controller: _nameController,
                      iconColor: Colors.blueAccent,
                    ),
                    const SizedBox(height: 16),

                    InputCompleted(
                      label: "Matrícula",
                      hint: "Ej. 20230001",
                      icon: Icons.badge,
                      controller: _matriculaController,
                      iconColor: Colors.amber,
                    ),
                    const SizedBox(height: 16),

                    const Label(text: "Nombre de la universidad"),
                    const SizedBox(height: 8),
                    UniversityAutocompleteField(
                      controller: _universityController,
                      isDark: isDark,
                      colors: colors,
                      onSelected: (selection) {
                        if (_selectedUniversityName != selection) {
                          setState(() {
                            _selectedUniversityName = selection;
                            _selectedCareerName = '';
                            _careerController.clear();
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    const Label(text: "Periodo actual"),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? colors.surfaceContainer
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedPeriod,
                          isExpanded: true,
                          menuMaxHeight: 250,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                            bottom: Radius.zero,
                          ),
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.deepOrange,
                          ),
                          style: TextStyle(
                            color: colors.onSurface,
                            fontSize: 15,
                          ),
                          dropdownColor: isDark
                              ? colors.surfaceContainer
                              : Colors.white,
                          items: _periodOptions.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              if (newValue != null) {
                                _selectedPeriod = newValue;
                                Provider.of<RegistrationProvider>(context, listen: false).periodName = newValue;
                              }
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (_selectedPeriod == 'Otro') ...[
                      const InputCompleted(
                        label: "Especificar otro periodo",
                        hint: "Ej. Modular",
                        icon: Icons.edit_calendar,
                        iconColor: Colors.teal,
                      ),
                      const SizedBox(height: 16),
                    ],

                    InputCompleted(
                      label: "Número de periodo (1ro, 2do, etc.)",
                      hint: "Ej. 4",
                      icon: Icons.format_list_numbered,
                      controller: _periodNumberController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      iconColor: Colors.deepOrangeAccent,
                    ),
                    const SizedBox(height: 16),

                    const Label(text: "Carrera"),
                    const SizedBox(height: 8),
                    CareerAutocompleteField(
                      controller: _careerController,
                      universityController: _universityController,
                      isDark: isDark,
                      colors: colors,
                      onSelected: (selection) {
                        if (_selectedCareerName != selection) {
                          setState(() {
                            _selectedCareerName = selection;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 32),

                    CorvusButton(
                      text: "Siguiente",
                      onPressed: _submitCareer,
                    ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading(ColorScheme colors, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(seconds: 2),
              builder: (context, value, child) {
                return Opacity(
                  opacity: 0.5 + (0.5 * Math.sin(value * Math.pi * 2)),
                  child: Image.asset(
                    'assets/icons/logo2.png',
                    width: 80,
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            Text(
              "Configurando tu perfil profesional...",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              "Nuestra IA está analizando la currícula de tu carrera para ofrecerte las mejores opciones de habilidades.",
              style: TextStyle(fontSize: 15, color: colors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            LinearProgressIndicator(
              color: colors.primary,
              backgroundColor: colors.surfaceContainerHighest,
            ),
          ],
        ),
      ),
    );
  }
}