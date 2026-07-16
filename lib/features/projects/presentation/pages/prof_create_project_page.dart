import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:mobile/features/projects/presentation/provider/project_provider.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';
import 'package:mobile/shared/widgets/corvus_top_bar.dart';
import 'package:mobile/shared/widgets/corvus_button.dart';
import 'package:mobile/shared/widgets/corvus_input_completed.dart';

class ProfCreateProjectPage extends StatefulWidget {
  const ProfCreateProjectPage({super.key});

  @override
  State<ProfCreateProjectPage> createState() => _ProfCreateProjectPageState();
}

class _ProfCreateProjectPageState extends State<ProfCreateProjectPage> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _teamSizeController = TextEditingController(text: '4');

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _teamSizeController.dispose();
    super.dispose();
  }

  void _createProject() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre es requerido')),
      );
      return;
    }

    final token = context.read<AuthProvider>().currentUser?.token;
    if (token == null) return;

    final provider = context.read<ProjectProvider>();
    final success = await provider.createProject(
      name: name,
      description: _descController.text.trim(),
      teamSize: int.tryParse(_teamSizeController.text) ?? 4,
      token: token,
    );

    if (!mounted) return;

    if (success) {
      final newProject = provider.myProjects.firstWhere((p) => p['name'] == name, orElse: () => null);
      if (newProject != null) {
        _showSuccessDialog(newProject['code']);
      } else {
        context.pop();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? 'Error al crear')),
      );
    }
  }

  void _showSuccessDialog(String code) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final colors = Theme.of(context).colorScheme;
        return AlertDialog(
          title: const Text('¡Proyecto Creado! 🎉', textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Comparte este código de acceso con tus alumnos para que puedan unirse y formar equipos:',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
                ),
                child: Text(
                  code,
                  style: TextStyle(
                    fontSize: 28,
                    letterSpacing: 4,
                    fontWeight: FontWeight.w900,
                    color: colors.primary,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: code));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Código copiado al portapapeles')),
                );
              },
              icon: const Icon(Icons.copy),
              label: const Text('Copiar'),
            ),
            FilledButton(
              onPressed: () {
                context.pop(); // Close dialog
                context.pop(); // Go back to dash
              },
              child: const Text('Entendido'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<ProjectProvider, bool>((p) => p.isLoading);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: const CorvusTopBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Nuevo Proyecto',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Al crear un proyecto, se generará un código para que tus alumnos se unan.',
              style: TextStyle(fontSize: 16, color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 32),
            InputCompleted(
              label: 'Nombre del Proyecto *',
              hint: 'Ej: Proyecto Final Integradora',
              icon: Icons.school_outlined,
              controller: _nameController,
              iconColor: colors.primary,
            ),
            const SizedBox(height: 16),
            InputCompleted(
              label: 'Descripción (Opcional)',
              hint: 'Detalles del proyecto...',
              icon: Icons.description_outlined,
              controller: _descController,
              iconColor: colors.primary,
            ),
            const SizedBox(height: 16),
            InputCompleted(
              label: 'Tamaño máximo del equipo',
              hint: '4',
              icon: Icons.groups_outlined,
              controller: _teamSizeController,
              iconColor: colors.primary,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 48),
            CorvusButton(
              text: isLoading ? 'Creando...' : 'Crear Proyecto',
              onPressed: isLoading ? () {} : _createProject,
            ),
          ],
        ),
      ),
    );
  }
}
