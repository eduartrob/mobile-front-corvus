import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/projects/presentation/provider/project_provider.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';
import 'package:mobile/shared/widgets/corvus_top_bar.dart';
import 'package:mobile/shared/widgets/corvus_button.dart';
import 'package:mobile/shared/widgets/corvus_input_completed.dart';

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
    if (code.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ingresa un código válido')));
      return;
    }

    final token = context.read<AuthProvider>().currentUser?.token;
    if (token == null) return;

    final provider = context.read<ProjectProvider>();
    final projectId = await provider.joinProject(code: code, token: token);

    if (!mounted) return;

    if (projectId != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Código válido! Ahora crea o únete a un equipo. 🎉'),
        ),
      );
      final isProfessor = [
        'PROFESOR',
        'DOCENTE',
        'ADMINISTRADOR',
      ].contains(context.read<AuthProvider>().currentUser?.role);
      if (isProfessor) {
        context.go('/prof-dash');
      } else {
        context.go('/project/$projectId/teams'); // Ir directamente al dashboard del equipo
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? 'Error al unirse')),
      );
    }
  }

  void _scanQr() async {
    final code = await context.push<String>('/student-qr-scanner');
    if (code != null && code.isNotEmpty) {
      _codeController.text = code;
      _joinProject();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<ProjectProvider, bool>((p) => p.isLoading);
    final colorScheme = Theme.of(context).colorScheme;
    final isProfessor = ['PROFESOR', 'DOCENTE', 'ADMINISTRADOR'].contains(context.read<AuthProvider>().currentUser?.role);

    return Scaffold(
      appBar: const CorvusTopBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.class_outlined, size: 80, color: colorScheme.primary),
            const SizedBox(height: 24),
            Text(
              'Unirse a una Clase',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              isProfessor 
                  ? 'Pídele a tu colega el Código de Acceso de 6 caracteres (ej. X7A-9BK) o escanea el Código QR para colaborar en el proyecto.' 
                  : 'Pídele a tu profesor el Código de Acceso de 6 caracteres (ej. X7A-9BK) e ingrésalo aquí para entrar al entorno del proyecto.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            InputCompleted(
              label: 'Código de Acceso',
              hint: 'X7A-9BK',
              icon: Icons.key_outlined,
              controller: _codeController,
              iconColor: colorScheme.primary,
            ),
            const SizedBox(height: 32),
            CorvusButton(
              text: isLoading ? 'Verificando...' : 'Unirse al Proyecto',
              onPressed: isLoading ? () {} : _joinProject,
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: isLoading ? null : _scanQr,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Escanear Código QR'),
            ),
          ],
        ),
        ),
      ),
    );
  }
}
