import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:mobile/shared/pages/in_app_browser_page.dart';
import 'package:confetti/confetti.dart';

class ProPlanPage extends StatefulWidget {
  const ProPlanPage({super.key});

  @override
  State<ProPlanPage> createState() => _ProPlanPageState();
}

class _ProPlanPageState extends State<ProPlanPage> with WidgetsBindingObserver {
  final List<Map<String, dynamic>> paymentMethods = [
    {'value': 'tarjeta', 'label': 'Tarjeta de Crédito / Débito', 'icon': Icons.credit_card_rounded},
    {'value': 'transferencia', 'label': 'Transferencia SPEI', 'icon': Icons.account_balance_rounded},
    {'value': 'efectivo', 'label': 'Pago en Efectivo (OXXO/Tiendas)', 'icon': Icons.storefront_rounded},
  ];
  String _selectedMethod = 'tarjeta';
  bool _isLoading = false;
  String? _paymentId;
  String? _paymentStatusMessage;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 4));
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuthProvider>().fetchProSubscriptionStatus().catchError((_) {});
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _confettiController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _paymentId != null) {
      _checkPaymentStatus();
    }
  }

  Future<void> _createPayment() async {
    setState(() {
      _isLoading = true;
      _paymentStatusMessage = null;
    });

    final isAsync = _selectedMethod == 'efectivo' || _selectedMethod == 'transferencia';

    final authProvider = context.read<AuthProvider>();
    try {
      final result = await authProvider.createPayment(metodo: _selectedMethod);
      _paymentId = result.id;

      if (mounted) {
        // The browser will auto-close when MercadoPago redirects to /pagos/resultado (tarjeta only)
        final returnedState = await Navigator.of(context).push<String>(
          MaterialPageRoute(
            builder: (context) => InAppBrowserPage(
              initialUrl: result.urlPago,
              title: 'Mercado Pago',
              // Only auto-close for card (auto_return); OXXO/SPEI don't redirect
              completionUrlFragment: isAsync ? null : '/pagos/resultado',
            ),
          ),
        );

        if (returnedState == 'aprobado') {
          // Tarjeta: browser auto-closed with approved state → verify immediately
          await _checkPaymentStatus();
        } else if (isAsync) {
          // OXXO / SPEI: user closed the browser manually after seeing the voucher.
          // Payment is NOT confirmed yet. The backend webhook will fire when they pay
          // and will send a Push notification automatically via RabbitMQ.
          setState(() {
            _paymentStatusMessage = _selectedMethod == 'efectivo'
                ? '📄 Tu ficha de pago fue generada. Paga en OXXO o tienda participante. '
                  'Cuando el pago se confirme recibirás una notificación y tu cuenta se actualizará automáticamente.'
                : '🏦 Los datos de transferencia SPEI fueron generados. '
                  'Realiza la transferencia y cuando se confirme recibirás una notificación automáticamente.';
          });
        } else {
          // Card but user closed manually (didn't finish) → check anyway
          _checkPaymentStatus();
        }
      }

    } catch (error) {
      _paymentStatusMessage = 'Error al iniciar el pago: ${error.toString()}';
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _checkPaymentStatus() async {
    if (_paymentId == null || _paymentId!.isEmpty) return;

    setState(() {
      _isLoading = true;
      _paymentStatusMessage = 'Verificando estado del pago...';
    });

    final authProvider = context.read<AuthProvider>();
    try {
      final status = await authProvider.checkPaymentStatus(_paymentId!);
      await authProvider.fetchProSubscriptionStatus().catchError((_) {});

      final String statusText = status['estado']?.toString() ?? status['status']?.toString() ?? 'desconocido';
      final bool paymentSuccess = status['activa'] == true || status['activa']?.toString().toLowerCase() == 'true';
      setState(() {
        if (paymentSuccess) {
          _paymentStatusMessage = '¡Pago confirmado! Ya disfrutas del Plan Pro.';
          _confettiController.play();
        } else if (statusText == 'pendiente') {
          if (_selectedMethod == 'efectivo' || _selectedMethod == 'transferencia') {
            _paymentStatusMessage = 'Pago pendiente de depósito (Puede tardar en reflejarse).';
          } else {
            _paymentStatusMessage = 'Pago cancelado o incompleto. Vuelve a intentarlo.';
            _paymentId = null; 
          }
        } else {
          _paymentStatusMessage = 'Estado de pago: $statusText';
        }
      });
    } catch (error) {
      setState(() {
        _paymentStatusMessage = 'Error al verificar el pago: ${error.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
                return Stack(
                  children: [
                    NestedScrollView(
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
                          _buildFreeTabContent(colors),
                          _buildProTabContent(colors, hasPro),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: ConfettiWidget(
                        confettiController: _confettiController,
                        blastDirection: pi / 2, // down
                        maxBlastForce: 5,
                        minBlastForce: 2,
                        emissionFrequency: 0.05,
                        numberOfParticles: 30,
                        gravity: 0.2,
                        colors: const [
                          Colors.blue,
                          Colors.blueAccent,
                          Colors.lightBlue,
                          Colors.indigo,
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildFreeTabContent(ColorScheme colors) {
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
            child: OutlinedButton(
              onPressed: () {
                DefaultTabController.of(context).animateTo(1);
              },
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                side: BorderSide(color: colors.primary, width: 2),
              ),
              child: Text(
                'Descubrir Plan Pro',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors.primary,
                ),
              ),
            ),
          ),
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
                    Text(
                      '\$50.00',
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
          const SizedBox(height: 40),
          Text(
            'Selecciona un método de pago',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          ...paymentMethods.map((method) => _buildPaymentMethodCard(
                context,
                value: method['value'],
                label: method['label'],
                icon: method['icon'],
                isSelected: _selectedMethod == method['value'],
                isDisabled: hasPro || _isLoading,
                onTap: () {
                  if (!hasPro && !_isLoading) {
                    setState(() {
                      _selectedMethod = method['value'];
                    });
                  }
                },
              )),
          const SizedBox(height: 24),
          if (_paymentStatusMessage != null) ...[
            Builder(
              builder: (context) {
                final msgLower = _paymentStatusMessage!.toLowerCase();
                final isSuccess = msgLower.contains('confirmado') || msgLower.contains('disfrutas') || msgLower.contains('aprobado');
                final isVerifying = msgLower.contains('verificando') || msgLower.contains('navegador');
                final isPending = msgLower.contains('pendiente');
                
                final bgColor = isSuccess
                    ? Colors.green.withOpacity(0.12)
                    : isVerifying
                        ? Colors.blue.withOpacity(0.12)
                        : isPending
                            ? Colors.amber.withOpacity(0.15)
                            : colors.errorContainer;

                final textColor = isSuccess
                    ? Colors.green[800]
                    : isVerifying
                        ? Colors.blue[800]
                        : isPending
                            ? Colors.amber[900]
                            : colors.error;

                final iconData = isSuccess
                    ? Icons.check_circle_outline
                    : isVerifying
                        ? Icons.sync
                        : isPending
                            ? Icons.access_time_rounded
                            : Icons.error_outline;

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(iconData, color: textColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _paymentStatusMessage!,
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
          SizedBox(
            width: double.infinity,
            height: 58,
            child: FilledButton(
              onPressed: hasPro || _isLoading ? null : _createPayment,
              style: FilledButton.styleFrom(
                backgroundColor: hasPro ? Colors.green : const Color(0xFF315BD5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : Text(
                      hasPro ? 'Plan Pro Activo' : 'Pagar ahora',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          if (!hasPro && _paymentId != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 58,
              child: OutlinedButton(
                onPressed: _isLoading ? null : _checkPaymentStatus,
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  side: BorderSide(color: colors.outlineVariant),
                ),
                child: Text(
                  'Verificar estado del pago',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 48),
        ],
      ),
    );
  }


  Widget _buildPaymentMethodCard(
    BuildContext context, {
    required String value,
    required String label,
    required IconData icon,
    required bool isSelected,
    required bool isDisabled,
    required VoidCallback onTap,
  }) {
    final colors = Theme.of(context).colorScheme;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected ? colors.primaryContainer.withOpacity(0.5) : colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? colors.primary : colors.outlineVariant.withOpacity(0.6),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colors.primary.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: isDisabled ? null : onTap,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSelected ? colors.primary.withOpacity(0.1) : colors.surfaceContainerHighest.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: isSelected ? colors.primary : colors.onSurfaceVariant,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                  Icon(
                    isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                    color: isSelected ? colors.primary : colors.outline,
                  ),
                ],
              ),
            ),
          ),
        ),
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
