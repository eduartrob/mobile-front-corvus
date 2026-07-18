import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/projects/presentation/provider/project_provider.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';
import 'package:mobile/shared/widgets/corvus_top_bar.dart';
import 'package:mobile/shared/widgets/corvus_button.dart';

class MyProjectsDashboardPage extends StatefulWidget {
  const MyProjectsDashboardPage({super.key});

  @override
  State<MyProjectsDashboardPage> createState() => _MyProjectsDashboardPageState();
}

class _MyProjectsDashboardPageState extends State<MyProjectsDashboardPage> {
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<AuthProvider>().currentUser?.token;
      if (token != null) {
        context.read<ProjectProvider>().loadMyProjects(token);
        
        // Configurar polling automático cada 10 segundos
        _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) {
          if (mounted) {
            final currentToken = context.read<AuthProvider>().currentUser?.token;
            if (currentToken != null) {
              context.read<ProjectProvider>().loadMyProjects(currentToken, quiet: true);
            }
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const CorvusTopBar(),
        floatingActionButton: context.select<ProjectProvider, bool>((p) => p.myProjects.isNotEmpty) ? FloatingActionButton.extended(
          onPressed: () => context.push('/join-project'),
          icon: const Icon(Icons.add),
          label: const Text('Unirse'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
        ) : null,
      body: Consumer<ProjectProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.myProjects.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.myProjects.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.class_outlined, size: 80, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(height: 24),
                    Text(
                      'Aún no tienes clases',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Únete a una clase ingresando el código que te proporcionó tu profesor para comenzar tu proyecto.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    CorvusButton(
                      text: 'Unirse a una Clase',
                      onPressed: () => context.push('/join-project'),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
              onRefresh: () async {
                final token = context.read<AuthProvider>().currentUser?.token;
                if (token != null) {
                  await provider.loadMyProjects(token);
                }
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: provider.myProjects.length,
                itemBuilder: (context, index) {
                final project = provider.myProjects[index];
                final pastelColors = const [
                  Color(0xFFEBF4FF), // Azul muy claro
                  Color(0xFFF4EBF7), // Morado muy claro
                  Color(0xFFEAF5EE), // Verde muy claro
                  Color(0xFFFEF2E5), // Naranja muy claro
                  Color(0xFFFCEAEF), // Rosa muy claro
                ];
                final bgColor = pastelColors[index % pastelColors.length];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        context.push('/project/${project['id']}/teams');
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.class_, color: Colors.white, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    project['name'] ?? 'Proyecto',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                              ],
                            ),
                          if (project['description'] != null && project['description'].toString().isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              project['description'].toString(),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                        ),
                      ),
                    ),
                  ),
                );
                },
              ),
            );
        },
      ),
    );
  }
}
