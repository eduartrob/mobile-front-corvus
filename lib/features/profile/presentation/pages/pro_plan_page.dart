import 'package:flutter/material.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

typedef PlanProPage = ProPlanPage;

class ProPlanPage extends StatefulWidget {
  const ProPlanPage({super.key});

  @override
  State<ProPlanPage> createState() => _ProPlanPageState();
}

class _ProPlanPageState extends State<ProPlanPage> with WidgetsBindingObserver {
  final List<Map<String, String>> paymentMethods = [
    {'value': 'tarjeta', 'label': 'Tarjeta'},
    {'value': 'transferencia', 'label': 'Transferencia'},
    {'value': 'efectivo', 'label': 'Efectivo'},
  ];
  String _selectedMethod = 'tarjeta';
  bool _isLoading = false;
  String? _paymentId;
  String? _paymentStatusMessage;

  @override
  void initState() {
    super.initState();
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

    final authProvider = context.read<AuthProvider>();
    try {
      final result = await authProvider.createPayment(metodo: _selectedMethod);
      _paymentId = result.id;
      _paymentStatusMessage = 'Abre el navegador para completar el pago y regresa a la app para verificar el estado.';

      final uri = Uri.parse(result.urlPago);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception('No se pudo abrir la URL de pago');
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
        _paymentStatusMessage = paymentSuccess
            ? 'Pago confirmado. ¡Plan Pro activo!'
            : 'Estado de pago: $statusText';
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
    final cardBgColor = Color.alphaBlend(
      colors.primary.withValues(alpha: 0.08),
      colors.surface,
    );

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: const Text('Plan Pro'),
        backgroundColor: colors.surface,
        scrolledUnderElevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 14),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: colors.primary.withValues(alpha: 0.15), width: 1.5),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      'Plan Pro',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: colors.onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Accede a todas las funciones avanzadas',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '\$99.00',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            color: colors.onSurface,
                            letterSpacing: -1.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '/ mes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildFeatureItem(context, 'Validaciones ilimitadas (borradores).'),
                    _buildFeatureItem(context, 'Simulador de Defensa por Voz (LLM).'),
                    _buildFeatureItem(context, 'Matchmaking global en tu escuela.'),
                    _buildFeatureItem(context, 'Soporte preferente y reportes avanzados.'),
                    const SizedBox(height: 32),
                    const Text(
                      'Método de pago',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Column(
                      children: paymentMethods.map((method) {
                        return RadioListTile<String>(
                          value: method['value']!,
                          groupValue: _selectedMethod,
                          title: Text(method['label']!),
                          onChanged: hasPro || _isLoading
                              ? null
                              : (value) {
                                  if (value != null) {
                                    setState(() {
                                      _selectedMethod = value;
                                    });
                                  }
                                },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    if (_paymentStatusMessage != null) ...[
                      Text(
                        _paymentStatusMessage!,
                        style: TextStyle(
                          color: _paymentStatusMessage!.toLowerCase().contains('error') ? Colors.red : Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton(
                        onPressed: hasPro || _isLoading ? null : _createPayment,
                        style: FilledButton.styleFrom(
                          backgroundColor: hasPro ? Colors.green : const Color(0xFF315BD5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          hasPro ? 'Plan Pro activo' : 'Adquirir Plan Pro',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    if (!hasPro && _paymentId != null) ...[
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : _checkPaymentStatus,
                          child: const Text('Verificar pago'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Positioned(
                top: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF315BD5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'MÁS POPULAR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, String text) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, color: const Color(0xFF315BD5), size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: colors.onSurface.withValues(alpha: 0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
