import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/features/profile/presentation/provider/profile_provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _matriculaController;
  late TextEditingController _cuatrimestreController;
  late TextEditingController _emailController;
  List<String> _selectedSkills = [];

  bool _isInit = false;

  final List<String> _allSkills = [
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final profile = Provider.of<ProfileProvider>(context, listen: false).profile;
      _nameController = TextEditingController(text: profile?.alumno ?? '');
      _matriculaController = TextEditingController(text: profile?.matricula ?? '');
      _cuatrimestreController = TextEditingController(text: profile?.cuatrimestre ?? '');
      _emailController = TextEditingController(text: profile?.correo ?? '');
      if (profile?.habilidades != null) {
        _selectedSkills = profile!.habilidades.map((h) => h.habilidad).toList();
      }
      _isInit = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _matriculaController.dispose();
    _cuatrimestreController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    final provider = Provider.of<ProfileProvider>(context, listen: false);
    try {
      await provider.updateProfile(
        fullName: _nameController.text,
        enrollmentId: _matriculaController.text,
        semester: _cuatrimestreController.text,
        skills: _selectedSkills,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado exitosamente'), backgroundColor: Colors.green),
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
      );
    }
  }

  void _showVerifyCodeDialog() {
    final codeController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        bool isVerifying = false;
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Ingresa el código'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Hemos enviado un código PIN a tu correo. Ingrésalo a continuación:'),
                  const SizedBox(height: 16),
                  TextField(
                    controller: codeController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Ej. 123456',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isVerifying ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: isVerifying ? null : () async {
                    setStateDialog(() => isVerifying = true);
                    final provider = Provider.of<ProfileProvider>(context, listen: false);
                    try {
                      await provider.confirmVerificationCode(codeController.text.trim());
                      if (!mounted) return;
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Correo verificado exitosamente'), backgroundColor: Colors.green),
                      );
                    } catch (e) {
                      setStateDialog(() => isVerifying = false);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
                      );
                    }
                  },
                  child: isVerifying
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Verificar'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  void _requestVerify() async {
    final provider = Provider.of<ProfileProvider>(context, listen: false);
    try {
      await provider.requestVerificationCode();
      if (!mounted) return;
      _showVerifyCodeDialog();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
      );
    }
  }

  void _toggleSkill(String skill) {
    setState(() {
      if (_selectedSkills.contains(skill)) {
        _selectedSkills.remove(skill);
      } else {
        if (_selectedSkills.length < 10) {
          _selectedSkills.add(skill);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Puedes seleccionar un máximo de 10 habilidades')),
          );
        }
      }
    });
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSkillsModal() {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Modificar Habilidades',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  Text(
                    'Elige hasta 10 habilidades que posees. (${_selectedSkills.length}/10)',
                    style: TextStyle(fontSize: 14, color: colors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          if (_selectedSkills.isNotEmpty) ...[
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              alignment: WrapAlignment.start,
                              children: _selectedSkills.map((s) => InkWell(
                                onTap: () {
                                  _toggleSkill(s);
                                  setModalState(() {});
                                },
                                child: Chip(
                                  label: Text(s),
                                  deleteIcon: const Icon(Icons.close, size: 18),
                                  onDeleted: () {
                                    _toggleSkill(s);
                                    setModalState(() {});
                                  },
                                  backgroundColor: colors.primary.withValues(alpha: 0.15),
                                  labelStyle: TextStyle(color: colors.primary, fontWeight: FontWeight.bold),
                                  side: BorderSide.none,
                                ),
                              )).toList(),
                            ),
                            const Divider(height: 32),
                          ],
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.start,
                            children: _allSkills
                                .where((s) => !_selectedSkills.contains(s))
                                .map((skill) => InkWell(
                                  onTap: () {
                                    _toggleSkill(skill);
                                    setModalState(() {});
                                  },
                                  child: Chip(
                                    label: Text(skill),
                                  ),
                                ))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final profile = profileProvider.profile;
    final isLoading = profileProvider.isLoading;
    final isVerified = profile?.isVerified ?? false; // Make sure to use the correct variable from backend! Let's check what it's mapped to in ProfileCompletoModel
    
    final colors = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Nombre Completo', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Tu nombre'),
          ),
          const SizedBox(height: 20),
          const Text('Matrícula / ID', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _matriculaController,
            decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Tu matrícula'),
          ),
          const SizedBox(height: 20),
          const Text('Cuatrimestre', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _cuatrimestreController,
            decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Ej. 8'),
          ),
          const SizedBox(height: 20),
          const Text('Carrera (No editable)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          TextField(
            controller: TextEditingController(text: profile?.carrera ?? ''),
            enabled: false,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: 20),
          const Text('Correo Electrónico', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _emailController,
            readOnly: true,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              suffixIcon: isVerified 
                ? const Icon(Icons.check_circle, color: Colors.green)
                : PopupMenuButton<String>(
                icon: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                tooltip: 'Verificar Correo',
                position: PopupMenuPosition.under,
                elevation: 3,
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    enabled: false,
                    child: Text(
                      'Tu correo no está verificado.',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'verify',
                    child: Row(
                      children: [
                        Icon(Icons.mark_email_read, size: 20),
                        SizedBox(width: 12),
                        Text('Enviar código de verificación'),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'verify') {
                    _requestVerify();
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Habilidades', style: TextStyle(fontWeight: FontWeight.bold)),
              TextButton.icon(
                onPressed: _showSkillsModal,
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Modificar'),
              ),
            ],
          ),
          if (_selectedSkills.isEmpty)
            const Text('Aún no has seleccionado habilidades', style: TextStyle(color: Colors.grey))
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedSkills.map((s) => Chip(
                label: Text(s),
                backgroundColor: colors.primary.withValues(alpha: 0.1),
                labelStyle: TextStyle(color: colors.primary, fontSize: 12),
                side: BorderSide.none,
              )).toList(),
            ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: isLoading ? null : _saveProfile,
              child: isLoading
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Guardar Cambios', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
