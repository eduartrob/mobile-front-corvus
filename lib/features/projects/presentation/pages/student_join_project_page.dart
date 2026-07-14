import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/projects/presentation/provider/project_provider.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';
import 'package:mobile/l10n/app_localizations.dart';

class StudentJoinProjectPage extends StatefulWidget {
  const StudentJoinProjectPage({super.key});

  @override
  State<StudentJoinProjectPage> createState() => _StudentJoinProjectPageState();
}

class _StudentJoinProjectPageState extends State<StudentJoinProjectPage> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _joinProject() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;

    final token = context.read<AuthProvider>().currentUser?.token;
    if (token == null) return;

    final provider = context.read<ProjectProvider>();
    final success = await provider.joinProject(code: code, token: token);

    if (!mounted) return;
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Te has unido al proyecto exitosamente!')),
      );
      context.go('/my-project'); // Ir al proyecto
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? 'Error al unirse')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<ProjectProvider, bool>((p) => p.isLoading);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Unirse a Proyecto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.class_, size: 80, color: colorScheme.primary),
            const SizedBox(height: 24),
            Text(
              'Ingresa el código del proyecto',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Pídele el código a tu profesor e ingrésalo aquí.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'Código (ej. X7A-9BK)',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isLoading ? null : _joinProject,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Unirse'),
            ),
          ],
        ),
      ),
    );
  }
}
