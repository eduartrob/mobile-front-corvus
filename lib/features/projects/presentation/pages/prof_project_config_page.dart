import 'package:flutter/material.dart';
import 'package:mobile/shared/widgets/corvus_top_bar.dart';
import 'package:provider/provider.dart';
import 'package:mobile/features/projects/presentation/provider/project_provider.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';
import 'package:mobile/features/projects/presentation/widgets/theme_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';

class ProfProjectConfigPage extends StatefulWidget {
  final String projectId;
  const ProfProjectConfigPage({super.key, required this.projectId});

  @override
  State<ProfProjectConfigPage> createState() => _ProfProjectConfigPageState();
}

class _ProfProjectConfigPageState extends State<ProfProjectConfigPage> {
  bool _isLoading = true;
  List<dynamic> _students = [];
  String? _projectCode;
  late TextEditingController _nameController;
  Color _selectedColor = ThemePicker.availableColors[0];
  String _selectedPattern = ThemePicker.availablePatterns[0];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final provider = context.read<ProjectProvider>();
    final token = context.read<AuthProvider>().currentUser?.token;
    
    // Find project to get name and code
    final project = provider.myProjects.firstWhere(
      (p) => p['id'] == widget.projectId,
      orElse: () => null,
    );

    if (project != null) {
      _nameController.text = project['name'] ?? '';
      _projectCode = project['code'];
      
      if (project['theme_color'] != null) {
        final colorStr = project['theme_color'].toString().replaceAll('#', '0xFF');
        _selectedColor = Color(int.parse(colorStr));
      }
      if (project['theme_pattern'] != null) {
        _selectedPattern = project['theme_pattern'];
      }
    }

    if (token != null) {
      final students = await provider.getProjectStudents(
        projectId: widget.projectId,
        token: token,
      );
      if (mounted) {
        setState(() {
          _students = students;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateName() async {
    final token = context.read<AuthProvider>().currentUser?.token;
    final provider = context.read<ProjectProvider>();
    final newName = _nameController.text.trim();

    if (newName.isEmpty || token == null) return;

    final success = await provider.updateProjectName(
      projectId: widget.projectId,
      newName: newName,
      token: token,
      themeColor: '#${_selectedColor.value.toRadixString(16).substring(2).toUpperCase()}',
      themePattern: _selectedPattern,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cambios guardados exitosamente')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Error al actualizar'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _showQrDialog() {
    if (_projectCode == null) return;
    
    // Deep link structure for scanning:
    final qrData = 'corvus-join:$_projectCode';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Código del Proyecto', textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  eyeStyle: QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  dataModuleStyle: QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SelectableText(
                _projectCode!,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2),
              ),
              const SizedBox(height: 8),
              const Text(
                'Muestra este código QR a los alumnos o dales el código para que se unan al proyecto.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _projectCode!));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Código copiado')),
                );
              },
              child: const Text('Copiar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar Proyecto'),
          content: const Text('¿Estás seguro de que deseas eliminar este proyecto? Esta acción no se puede deshacer.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
              onPressed: () async {
                Navigator.pop(context);
                final token = context.read<AuthProvider>().currentUser?.token;
                final provider = context.read<ProjectProvider>();
                if (token != null) {
                  final success = await provider.deleteProject(projectId: widget.projectId, token: token);
                  if (mounted) {
                    if (success) {
                      Navigator.pop(context); // Go back to previous screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Proyecto eliminado exitosamente')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(provider.error ?? 'Error al eliminar'),
                          backgroundColor: Theme.of(context).colorScheme.error,
                        ),
                      );
                    }
                  }
                }
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: const CorvusTopBar(
        titleWidget: Text('Configuración del Proyecto'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Change Name Section
                  Text(
                    'Nombre del Proyecto',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: 'Ej. Proyecto Integrador',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  ThemePicker(
                    selectedColor: _selectedColor,
                    selectedPattern: _selectedPattern,
                    onColorChanged: (color) => setState(() => _selectedColor = color),
                    onPatternChanged: (pattern) => setState(() => _selectedPattern = pattern),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _updateName,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Guardar Cambios'),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // QR Code Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.qr_code_2, size: 48, color: colorScheme.onPrimaryContainer),
                        const SizedBox(height: 12),
                        Text(
                          'Invitar alumnos',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Comparte el código QR para que los alumnos se unan al proyecto rápidamente.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: colorScheme.onPrimaryContainer.withValues(alpha: 0.8)),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: _showQrDialog,
                          icon: const Icon(Icons.share),
                          label: const Text('Mostrar QR'),
                          style: FilledButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Students List
                  Text(
                    'Alumnos Inscritos',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_students.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          children: [
                            Icon(Icons.people_outline, size: 64, color: colorScheme.outline),
                            const SizedBox(height: 16),
                            Text(
                              'No hay alumnos unidos a este proyecto aún.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _students.length,
                      itemBuilder: (context, index) {
                        final s = _students[index];
                        final name = s['full_name'] ?? s['username'] ?? 'Alumno';
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: colorScheme.secondaryContainer,
                              backgroundImage: s['profile_picture'] != null ? NetworkImage(s['profile_picture']) : null,
                              child: s['profile_picture'] == null
                                  ? Text(name.substring(0, 1).toUpperCase(), style: TextStyle(color: colorScheme.onSecondaryContainer))
                                  : null,
                            ),
                            title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(s['email'] ?? ''),
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 48),

                  // Delete Project Button
                  Center(
                    child: OutlinedButton.icon(
                      onPressed: _showDeleteDialog,
                      icon: Icon(Icons.delete_forever, color: colorScheme.error),
                      label: Text(
                        'Eliminar Proyecto',
                        style: TextStyle(color: colorScheme.error),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: colorScheme.error),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}
