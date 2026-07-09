import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/features/profile/presentation/provider/profile_provider.dart';

class EditSkillsPage extends StatefulWidget {
  final List<String> initialSkills;

  const EditSkillsPage({super.key, required this.initialSkills});

  @override
  State<EditSkillsPage> createState() => _EditSkillsPageState();
}

class _EditSkillsPageState extends State<EditSkillsPage> {
  late List<String> _selectedSkills;
  bool _isLoading = false;

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
  void initState() {
    super.initState();
    _selectedSkills = List.from(widget.initialSkills);
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

  Future<void> _handleSave() async {
    setState(() => _isLoading = true);
    final provider = Provider.of<ProfileProvider>(context, listen: false);
    final profile = provider.profile;
    
    try {
      await provider.updateProfile(
        fullName: profile?.alumno ?? '',
        enrollmentId: profile?.matricula ?? '',
        semester: profile?.cuatrimestre ?? '',
        skills: _selectedSkills,
      );
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
                  color: isSelected ? colors.primary : colors.onSurface,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final sortedSkills = List<String>.from(_allSkills)
      ..sort((a, b) {
        final aSelected = _selectedSkills.contains(a);
        final bSelected = _selectedSkills.contains(b);
        if (aSelected && !bSelected) return -1;
        if (!aSelected && bSelected) return 1;
        return 0; // Mantiene el orden original para las no seleccionadas
      });

    return Scaffold(
      appBar: AppBar(
        title: Text('Habilidades', style: TextStyle(color: colors.onSurfaceVariant)),
        iconTheme: IconThemeData(color: colors.onSurfaceVariant),
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        leadingWidth: 48,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selecciona hasta 10 habilidades que destaquen tu perfil:',
                      style: TextStyle(color: colors.onSurfaceVariant, fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: sortedSkills.map((skill) {
                        return _buildSkillChip(
                          skill,
                          _selectedSkills.contains(skill),
                          colors,
                          isDark,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                top: 16.0,
                bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 16.0 : 32.0,
              ),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isLoading ? null : _handleSave,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Guardar', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
