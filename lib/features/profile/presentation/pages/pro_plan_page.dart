import 'package:flutter/material.dart';
import 'package:mobile/shared/presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:mobile/features/profile/presentation/pages/payment_checkout_page.dart';

class ProPlanPage extends StatefulWidget {
  const ProPlanPage({super.key});

  @override
  State<ProPlanPage> createState() => _ProPlanPageState();
}

class _ProPlanPageState extends State<ProPlanPage> {
  double? _proPrice;
  bool _loadingPrice = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuthProvider>().fetchProSubscriptionStatus().catchError((_) {});
        context.read<AuthProvider>().fetchPlanPrice('Plan Pro mensual').then((price) {
          if (mounted) setState(() { _proPrice = price; _loadingPrice = false; });
        }).catchError((_) {
          if (mounted) setState(() { _loadingPrice = false; });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final authProvider = context.watch<AuthProvider>();
    final hasPro = authProvider.isProActive;

    return DefaultTabController(
      length: 2,
      initialIndex: hasPro ? 1 : 0,
      child: Builder(
        builder: (context) {
          final tabController = DefaultTabController.of(context);
          return Scaffold(
            backgroundColor: colors.surface,
            body: AnimatedBuilder(
              animation: tabController,
              builder: (context, child) {
                final isProTab = tabController.index == 1;
                return NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      SliverAppBar(
                        expandedHeight: 220,
                        pinned: true,
                        backgroundColor: colors.surface,
                        flexibleSpace: FlexibleSpaceBar(
                          background: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isProTab 
                                  ? [const Color(0xFF315BD5), const Color(0xFF1E3A8A)]
                                  : [Colors.grey.shade700, Colors.grey.shade900],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  top: -40,
                                  right: -40,
                                  child: Icon(
                                    isProTab ? Icons.workspace_premium : Icons.explore_rounded, 
                                    size: 200, 
                                    color: Colors.white.withOpacity(0.1)
                                  ),
                                ),
                                Positioned(
                                  bottom: 60,
                                  left: 24,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        isProTab ? 'Plan Pro' : 'Plan Free',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 34,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: -1,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        isProTab ? 'Desbloquea todo el poder de Corvus' : 'Comienza a explorar sin costo',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        iconTheme: const IconThemeData(color: Colors.white),
                        bottom: const TabBar(
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.white70,
                          indicatorColor: Colors.white,
                          indicatorWeight: 3,
                          tabs: [
                            Tab(text: 'Plan Free'),
                            Tab(text: 'Plan Pro'),
                          ],
                        ),
                      ),
                    ];
                  },
                  body: TabBarView(
                    children: [
                      _buildFreeTabContent(colors, hasPro),
                      _buildProTabContent(colors, hasPro),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildFreeTabContent(ColorScheme colors, bool hasPro) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest.withOpacity(0.3),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: colors.outlineVariant.withOpacity(0.5)),
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '\$0.00',
                      style: TextStyle(
                        fontSize: 46,
                        fontWeight: FontWeight.w900,
                        color: colors.onSurface,
                        letterSpacing: -1.5,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
                      child: Text(
                        '/ siempre',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildFeatureItem(
                  context,
                  icon: Icons.text_snippet_rounded,
                  title: 'Defensa por texto básica',
                  subtitle: 'Hasta 10 respuestas escritas por sesión de examen.',
                  badgeText: 'GRATIS',
                ),
                _buildFeatureItem(
                  context,
                  icon: Icons.analytics_rounded,
                  title: 'Análisis 2 veces de propuesta',
                  subtitle: 'Detección de innovación y recomendación de la IA.',
                ),
                _buildFeatureItem(
                  context,
                  icon: Icons.search_off_rounded,
                  title: 'Pocos proyectos inexplorados',
                  subtitle: 'Acceso solo a algunos proyectos del repositorio.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 58,
            child: FilledButton(
              onPressed: !hasPro ? null : () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: colors.surface,
                    title: Text('Cambiar a Plan Free', style: TextStyle(color: colors.onSurface)),
                    content: Text(
                      '¿Estás seguro de que deseas cancelar tu suscripción Pro? Perderás acceso a validaciones ilimitadas y herramientas premium.',
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancelar'),
                      ),
                      FilledButton(
                        onPressed: () async {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Cancelando suscripción...')),
                          );
                          await context.read<AuthProvider>().downgradeToFree();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Plan Free activado correctamente')),
                            );
                          }
                        },
                        style: FilledButton.styleFrom(backgroundColor: colors.error),
                        child: const Text('Confirmar'),
                      ),
                    ],
                  ),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: !hasPro ? colors.surfaceContainerHighest : Colors.grey.shade800,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                !hasPro ? 'Tu plan actual' : 'Adquirir Plan Free',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: !hasPro ? colors.onSurfaceVariant : Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildProTabContent(ColorScheme colors, bool hasPro) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest.withOpacity(0.3),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: colors.outlineVariant.withOpacity(0.5)),
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_loadingPrice)
                      const SizedBox(
                        width: 28, height: 28,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      )
                    else
                      Text(
                        _proPrice != null
                            ? '\$${_proPrice!.toStringAsFixed(2)}'
                            : '\$50.00',
                        style: TextStyle(
                          fontSize: 46,
                          fontWeight: FontWeight.w900,
                          color: colors.onSurface,
                          letterSpacing: -1.5,
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
                      child: Text(
                        '/ mes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildFeatureItem(
                  context,
                  icon: Icons.swap_calls_rounded,
                  title: 'Validaciones ilimitadas de Propuesta',
                  subtitle: 'Análisis de colisión semántica e innovación sin restricciones.',
                  badgeText: 'ILIMITADO',
                ),
                _buildFeatureItem(
                  context,
                  icon: Icons.record_voice_over_rounded,
                  title: 'Simulador por Voz Gemini Live',
                  subtitle: 'Evaluación oral y escrita en tiempo real sin restricciones.',
                  badgeText: 'VOZ HD',
                ),
                _buildFeatureItem(
                  context,
                  icon: Icons.workspace_premium_rounded,
                  title: 'Acceso completo a todos los proyectos inexplorados',
                  subtitle: 'Explora el repositorio completo de proyectos pasados sin límite.',
                  badgeText: 'PRO',
                ),
                _buildFeatureItem(
                  context,
                  icon: Icons.shield_rounded,
                  title: 'Insignia VIP Dorada',
                  subtitle: 'Destaca entre los proyectos de tu facultad y accede a matchmaking exclusivo.',
                  badgeText: 'VIP',
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 58,
            child: FilledButton(
              onPressed: hasPro ? null : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PaymentCheckoutPage(proPrice: _proPrice)),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: hasPro ? colors.surfaceContainerHighest : const Color(0xFF315BD5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                hasPro ? 'Tu plan actual' : 'Obtener Plan PRO',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: hasPro ? colors.onSurfaceVariant : Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    String? badgeText,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF315BD5).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF315BD5), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          color: colors.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (badgeText != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.amber.shade700, width: 0.8),
                        ),
                        child: Text(
                          badgeText,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade900,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
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

