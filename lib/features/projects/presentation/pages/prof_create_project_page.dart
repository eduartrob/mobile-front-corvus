import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/projects/presentation/provider/project_provider.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';

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
    if (name.isEmpty) return;

    final token = context.read<AuthProvider>().accessToken;
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Proyecto creado exitosamente')),
      );
      context.pop(); // Volver al dashboard
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? 'Error al crear')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<ProjectProvider, bool>((p) => p.isLoading);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Proyecto'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Al crear un proyecto, se generará un código para que tus alumnos se unan.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del Proyecto *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: 'Descripción (Opcional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _teamSizeController,
              decoration: const InputDecoration(
                labelText: 'Tamaño máximo de equipo',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: isLoading ? null : _createProject,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Crear Proyecto'),
            ),
          ],
        ),
      ),
    );
  }
}
