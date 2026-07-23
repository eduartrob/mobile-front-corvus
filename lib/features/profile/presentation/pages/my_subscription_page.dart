import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';
import 'pro_plan_page.dart';

class MySubscriptionPage extends StatefulWidget {
  const MySubscriptionPage({super.key});

  @override
  State<MySubscriptionPage> createState() => _MySubscriptionPageState();
}

class _MySubscriptionPageState extends State<MySubscriptionPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuthProvider>().fetchProSubscriptionStatus().catchError((_) {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = context.watch<AuthProvider>();
    final hasPro = authProvider.isProActive;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: const Text(
          'Mi Plan Actual',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        elevation: 0,
        backgroundColor: colors.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tarjeta de Estado de Suscripción Actual
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: hasPro
                    ? const LinearGradient(
                        colors: [Color(0xFFD97706), Color(0xFFB45309), Color(0xFF78350F)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                            : [const Color(0xFFE2E8F0), const Color(0xFFCBD5E1)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: hasPro
                        ? Colors.amber.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: hasPro
                              ? Colors.black.withValues(alpha: 0.3)
                              : (isDark ? Colors.white12 : Colors.white),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              hasPro ? Icons.workspace_premium : Icons.stars_rounded,
                              color: hasPro ? Colors.amber : (isDark ? Colors.white70 : Colors.black87),
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              hasPro ? 'PLAN PRO ACTIVO' : 'PLAN GRATUITO ESTÁNDAR',
                              style: TextStyle(
                                color: hasPro ? Colors.amber : (isDark ? Colors.white : Colors.black87),
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        hasPro ? '\$50.00 / mes' : 'Gratis',
                        style: TextStyle(
                          color: hasPro ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    hasPro
                        ? '¡Tienes acceso completo ilimitado a todas las herramientas PRO!'
                        : 'Estás utilizando la versión Estándar Gratuita.',
                    style: TextStyle(
                      color: hasPro ? Colors.white : (isDark ? Colors.white : const Color(0xFF1E293B)),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    hasPro
                        ? 'Tu membresía incluye Validaciones Ilimitadas, Simulador de Defensa completo y Acceso a todos los proyectos inexplorados.'
                        : 'Puedes validar tus propuestas en modo básico o actualizar al Plan Pro para desbloquear validaciones ilimitadas y el simulador completo.',
                    style: TextStyle(
                      color: hasPro ? Colors.white.withValues(alpha: 0.87) : (isDark ? Colors.white70 : Colors.black87),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Título Beneficios de tu plan
            Text(
              'Lo que incluye tu plan actual:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
            ),

            const SizedBox(height: 14),

            // Lista de Beneficios del Plan Actual
            if (hasPro) ...[
              _buildFeatureRow(
                context,
                icon: Icons.picture_as_pdf_rounded,
                title: 'Validaciones ilimitadas de Propuesta',
                subtitle: 'Análisis de colisión semántica e innovación sin restricciones.',
                isIncluded: true,
              ),
              _buildFeatureRow(
                context,
                icon: Icons.record_voice_over_rounded,
                title: 'Simulador de defensa oral y escrito ilimitado',
                subtitle: 'Evaluación oral y escrita sin restricciones.',
                isIncluded: true,
              ),
              _buildFeatureRow(
                context,
                icon: Icons.workspace_premium_rounded,
                title: 'Acceso completo a todos los proyectos inexplorados',
                subtitle: 'Explora el repositorio completo de proyectos pasados sin límite.',
                isIncluded: true,
              ),
            ] else ...[
              _buildFeatureRow(
                context,
                icon: Icons.text_snippet_rounded,
                title: 'Defensa por texto básica',
                subtitle: 'Hasta 10 respuestas escritas por sesión de examen.',
                isIncluded: true,
              ),
              _buildFeatureRow(
                context,
                icon: Icons.analytics_rounded,
                title: 'Análisis 2 veces de propuesta',
                subtitle: 'Detección de innovación y recomendación de la IA.',
                isIncluded: true,
              ),
              _buildFeatureRow(
                context,
                icon: Icons.search_off_rounded,
                title: 'Pocos proyectos inexplorados',
                subtitle: 'Acceso solo a algunos proyectos del repositorio.',
                isIncluded: true,
              ),
              const Divider(height: 32),
              Text(
                'Bloqueado en tu plan actual:',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              _buildFeatureRow(
                context,
                icon: Icons.picture_as_pdf_rounded,
                title: 'Validaciones ilimitadas de Propuesta',
                subtitle: 'Requiere Plan Pro para análisis sin restricciones.',
                isIncluded: false,
              ),
              _buildFeatureRow(
                context,
                icon: Icons.record_voice_over_rounded,
                title: 'Simulador por Voz Gemini Live',
                subtitle: 'Requiere Plan Pro para evaluación oral y escrita en tiempo real sin límite.',
                isIncluded: false,
              ),
              _buildFeatureRow(
                context,
                icon: Icons.workspace_premium_rounded,
                title: 'Acceso completo a todos los proyectos inexplorados',
                subtitle: 'Requiere Plan Pro para explorar el repositorio completo.',
                isIncluded: false,
              ),
              _buildFeatureRow(
                context,
                icon: Icons.shield_rounded,
                title: 'Insignia VIP Dorada',
                subtitle: 'Requiere Plan Pro para destacar y acceder a matchmaking exclusivo.',
                isIncluded: false,
              ),
            ],

            const SizedBox(height: 32),

            // Botón de Acción Principal (Mejorar / Cambiar Plan)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasPro ? colors.primary : Colors.amber.shade700,
                  foregroundColor: hasPro ? Colors.white : Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                icon: Icon(
                  hasPro ? Icons.settings_applications_rounded : Icons.rocket_launch_rounded,
                  size: 20,
                ),
                label: Text(
                  hasPro ? 'VER O CAMBIAR DETALLES DE PLAN PRO' : 'MEJORAR MI PLAN A PRO (\$50.00 / mes)',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 0.3,
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProPlanPage()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isIncluded,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isIncluded
                  ? Colors.green.withValues(alpha: 0.12)
                  : colors.onSurfaceVariant.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isIncluded ? Icons.check_circle_rounded : Icons.lock_outline_rounded,
              color: isIncluded ? Colors.green : colors.onSurfaceVariant.withValues(alpha: 0.6),
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isIncluded ? colors.onSurface : colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.onSurfaceVariant,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
