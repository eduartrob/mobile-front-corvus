import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mobile/core/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:mobile/shared/pages/in_app_browser_page.dart';
import 'package:confetti/confetti.dart';

class PaymentCheckoutPage extends StatefulWidget {
  final double? proPrice;
  
  const PaymentCheckoutPage({super.key, this.proPrice});

  @override
  State<PaymentCheckoutPage> createState() => _PaymentCheckoutPageState();
}

class _PaymentCheckoutPageState extends State<PaymentCheckoutPage> with WidgetsBindingObserver {
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
        final returnedState = await Navigator.of(context).push<String>(
          MaterialPageRoute(
            builder: (context) => InAppBrowserPage(
              initialUrl: result.urlPago,
              title: 'Mercado Pago',
              completionUrlFragment: isAsync ? null : '/pagos/resultado',
            ),
          ),
        );

        if (returnedState == 'aprobado') {
          await _checkPaymentStatus();
        } else if (isAsync) {
          setState(() {
            _paymentStatusMessage = _selectedMethod == 'efectivo'
                ? '📄 Tu ficha de pago fue generada. Paga en OXXO o tienda participante. '
                  'Cuando el pago se confirme recibirás una notificación y tu cuenta se actualizará automáticamente.'
                : '🏦 Los datos de transferencia SPEI fueron generados. '
                  'Realiza la transferencia y cuando se confirme recibirás una notificación automáticamente.';
          });
        } else {
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Completar Adquisición'),
        backgroundColor: colors.surface,
      ),
      backgroundColor: colors.surface,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF315BD5).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFF315BD5).withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.workspace_premium_rounded, color: Color(0xFF315BD5), size: 40),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Plan Pro',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF315BD5),
                              ),
                            ),
                            Text(
                              widget.proPrice != null
                                  ? '\$${widget.proPrice!.toStringAsFixed(2)} / mes'
                                  : '\$50.00 / mes',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
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
}
