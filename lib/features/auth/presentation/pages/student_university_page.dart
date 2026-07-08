import 'dart:convert';
import 'dart:math' as Math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/theme/app_dimens.dart';
import 'package:mobile/shared/widgets/corvus_input.dart';
import 'package:mobile/shared/widgets/corvus_input_completed.dart';
import 'package:mobile/shared/widgets/corvus_button.dart';
import 'package:mobile/shared/widgets/corvus_label.dart';
import 'package:mobile/core/network/api_config.dart';
import 'package:mobile/core/network/auth_interceptor_client.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/features/auth/presentation/provider/registration_provider.dart';
import 'package:provider/provider.dart';
import 'package:mobile/shared/widgets/auth_layout.dart';

class StudentUniversityPage extends StatefulWidget {
  const StudentUniversityPage({super.key});

  @override
  State<StudentUniversityPage> createState() => _StudentUniversityPageState();
}

class _StudentUniversityPageState extends State<StudentUniversityPage> {
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

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<RegistrationProvider>(context, listen: false);
    
    if (provider.fullName.isNotEmpty) _nameController.text = provider.fullName;
    if (provider.matricula.isNotEmpty) _matriculaController.text = provider.matricula;
    if (provider.universityName.isNotEmpty) _universityController.text = provider.universityName;
    if (provider.careerName.isNotEmpty) _careerController.text = provider.careerName;
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

  @override
  void dispose() {
    _nameController.dispose();
    _matriculaController.dispose();
    _universityController.dispose();
    _careerController.dispose();
    _periodNumberController.dispose();
    super.dispose();
  }

  Future<List<String>> _getUniversities(String query) async {
    if (query.isEmpty || query.length < 2) return [];

    _lastQuery = query;
    await Future.delayed(const Duration(milliseconds: 300));
    if (_lastQuery != query) return []; // debounced

    try {
      final response = await http
          .get(
            Uri.parse(
              '${ApiConfig.apiGatewayUrl}/auth/universities?search=$query',
            ),
          )
          .timeout(const Duration(seconds: 10));

      if (_lastQuery != query) return []; // stale response

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((u) => u['name'].toString()).toList();
      }
    } catch (e) {
      debugPrint("Error fetching universities: $e");
    }
    return [];
  }

  Future<List<String>> _getCareers(String query) async {
    if (query.isEmpty || query.length < 2) return [];

    _lastQuery = query;
    await Future.delayed(const Duration(milliseconds: 300));
    if (_lastQuery != query) return [];

    try {
      final universityName = Uri.encodeComponent(_universityController.text.trim());
      final response = await http
          .get(
            Uri.parse(
              '${ApiConfig.apiGatewayUrl}/auth/careers?search=$query&universityId=$universityName',
            ),
          )
          .timeout(const Duration(seconds: 10));

      if (_lastQuery != query) return [];

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((c) => c['name'].toString()).toList();
      }
    } catch (e) {
      debugPrint("Error fetching careers: $e");
    }
    return [];
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

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.onSurface),
          onPressed: () {
            // Force save just in case
            final provider = Provider.of<RegistrationProvider>(context, listen: false);
            provider.fullName = _nameController.text;
            provider.matricula = _matriculaController.text;
            provider.universityName = _universityController.text;
            provider.careerName = _careerController.text;
            provider.periodNumber = _periodNumberController.text;
            context.pop();
          },
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? _buildShimmerLoading(colors, isDark)
            : SingleChildScrollView(
                child: AuthLayout(
                  appTitle: 'Corvus',
                  cardTitle: 'Información institucional',
                  children: [
                    const Label(text: "Nombre completo"),
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
                        border: Border.all(
                          color: isDark
                              ? colors.outlineVariant.withValues(
                                  alpha: 0.5,
                                )
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: TextField(
                        controller: _nameController,
                        style: TextStyle(
                          color: colors.onSurface,
                          fontSize: 15,
                        ),
                        decoration: InputDecoration(
                          hintText: "Ej. Juan Pérez García",
                          hintStyle: TextStyle(
                            color: colors.onSurfaceVariant.withValues(
                              alpha: 0.6,
                            ),
                          ),
                          border: InputBorder.none,
                          icon: Icon(
                            Icons.person,
                            color: Colors.blueAccent,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Label(text: "Matrícula"),
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
                        border: Border.all(
                          color: isDark
                              ? colors.outlineVariant.withValues(
                                  alpha: 0.5,
                                )
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: TextField(
                        controller: _matriculaController,
                        style: TextStyle(
                          color: colors.onSurface,
                          fontSize: 15,
                        ),
                        decoration: InputDecoration(
                          hintText: "Ej. 20230001",
                          hintStyle: TextStyle(
                            color: colors.onSurfaceVariant.withValues(
                              alpha: 0.6,
                            ),
                          ),
                          border: InputBorder.none,
                          icon: Icon(
                            Icons.badge,
                            color: Colors.amber,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Label(text: "Nombre de la universidad"),
                    const SizedBox(height: 8),
                    Autocomplete<String>(
                      initialValue: TextEditingValue(text: _universityController.text),
                      optionsBuilder:
                          (TextEditingValue textEditingValue) async {
                            return await _getUniversities(
                              textEditingValue.text,
                            );
                          },
                      onSelected: (String selection) {
                        _universityController.text = selection;
                      },
                      fieldViewBuilder:
                          (
                            context,
                            controller,
                            focusNode,
                            onEditingComplete,
                          ) {
                            // Add a listener once to sync the text
                            WidgetsBinding.instance
                                .addPostFrameCallback((_) {
                                  if (controller.text !=
                                      _universityController.text) {
                                    _universityController.text =
                                        controller.text;
                                  }
                                });

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? colors.surfaceContainer
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDark
                                      ? colors.outlineVariant
                                            .withValues(alpha: 0.5)
                                      : const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: TextField(
                                controller: controller,
                                focusNode: focusNode,
                                onEditingComplete: () {
                                  _universityController.text =
                                      controller.text;
                                  onEditingComplete();
                                },
                                onChanged: (val) {
                                  _universityController.text = val;
                                },
                                style: TextStyle(
                                  color: colors.onSurface,
                                  fontSize: 15,
                                ),
                                decoration: InputDecoration(
                                  hintText:
                                      "Ej. Universidad Nacional...",
                                  hintStyle: TextStyle(
                                    color: colors.onSurfaceVariant
                                        .withValues(alpha: 0.6),
                                  ),
                                  border: InputBorder.none,
                                  icon: Icon(
                                    Icons.account_balance,
                                    color: Colors.deepPurpleAccent,
                                    size: 20,
                                  ),
                                ),
                              ),
                            );
                          },
                      optionsViewBuilder: (
                        context,
                        onSelected,
                        options,
                      ) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            elevation: 4.0,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width:
                                  MediaQuery.of(context).size.width -
                                  64,
                              constraints: const BoxConstraints(
                                maxHeight: 200,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? colors.surfaceContainer
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(
                                  12,
                                ),
                              ),
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: options.length,
                                itemBuilder: (
                                  BuildContext context,
                                  int index,
                                ) {
                                  final String option =
                                      options.elementAt(index);
                                  return InkWell(
                                    onTap: () {
                                      onSelected(option);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(
                                        16.0,
                                      ),
                                      child: Text(
                                        option,
                                        style: TextStyle(
                                          color: colors.onSurface,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
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
                        border: Border.all(
                          color: isDark
                              ? colors.outlineVariant.withValues(
                                  alpha: 0.5,
                                )
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedPeriod,
                          isExpanded: true,
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
                    Autocomplete<String>(
                      initialValue: TextEditingValue(text: _careerController.text),
                      optionsBuilder: (TextEditingValue textEditingValue) async {
                        return await _getCareers(textEditingValue.text);
                      },
                      onSelected: (String selection) {
                        _careerController.text = selection;
                      },
                      fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (controller.text != _careerController.text) {
                            _careerController.text = controller.text;
                          }
                        });

                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: isDark ? colors.surfaceContainer : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? colors.outlineVariant.withValues(alpha: 0.5) : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: TextField(
                            controller: controller,
                            focusNode: focusNode,
                            onEditingComplete: () {
                              _careerController.text = controller.text;
                              onEditingComplete();
                            },
                            onChanged: (val) {
                              _careerController.text = val;
                            },
                            style: TextStyle(
                              color: colors.onSurface,
                              fontSize: 15,
                            ),
                            decoration: InputDecoration(
                              hintText: "Ej. Ingeniería de Software",
                              hintStyle: TextStyle(
                                color: colors.onSurfaceVariant.withValues(alpha: 0.6),
                              ),
                              border: InputBorder.none,
                              icon: Icon(
                                Icons.school,
                                color: Colors.greenAccent,
                                size: 20,
                              ),
                            ),
                          ),
                        );
                      },
                      optionsViewBuilder: (context, onSelected, options) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            elevation: 4.0,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: MediaQuery.of(context).size.width - 64,
                              constraints: const BoxConstraints(maxHeight: 200),
                              decoration: BoxDecoration(
                                color: isDark ? colors.surfaceContainerHigh : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                itemCount: options.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final String option = options.elementAt(index);
                                  return InkWell(
                                    onTap: () {
                                      onSelected(option);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Text(
                                        option,
                                        style: TextStyle(
                                          color: colors.onSurface,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),

                    CorvusButton(
                      text: "Siguiente",
                      onPressed: _submitCareer,
                    ),
                  ],
                ),
              ),
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
                  child: SvgPicture.asset(
                    'assets/icons/logo.svg',
                    width: 80,
                    colorFilter: ColorFilter.mode(
                      colors.primary,
                      BlendMode.srcIn,
                    ),
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
