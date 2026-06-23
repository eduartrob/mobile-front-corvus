import 'package:flutter/material.dart';
import 'package:mobile/src/plugin/atom/button.dart';
import 'package:flutter/services.dart';

class VerifyIdentityForm extends StatefulWidget {
  final String email;

  const VerifyIdentityForm({super.key, this.email = 'u***@example.com'});

  @override
  State<VerifyIdentityForm> createState() => _VerifyIdentityFormState();
}

class _VerifyIdentityFormState extends State<VerifyIdentityForm> {
  late List<TextEditingController> controllers;
  late List<FocusNode> focusNodes;

  @override
  void initState() {
    super.initState();
    controllers = List.generate(6, (_) => TextEditingController());
    focusNodes = List.generate(6, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _handleCodeInput(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      focusNodes[index + 1].requestFocus();
    }
  }

  void _handleCodeDelete(String value, int index) {
    if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }
  }

  String getCode() => controllers.map((c) => c.text).join();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFB266FF), width: 2),
            ),
            child: const Icon(
              Icons.verified_user,
              color: Color(0xFFB266FF),
              size: 32,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Verifica tu identidad',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Hemos enviado un código a tu correo',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          Text(
            widget.email,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 28),

          // OTP Input Fields
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              6,
              (index) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: SizedBox(
                    height: 48,
                    child: TextField(
                      controller: controllers[index],
                      focusNode: focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      inputFormatters: [
                        TextInputFormatter.withFunction(
                          (oldValue, newValue) {
                            if (newValue.text.isEmpty) {
                              _handleCodeDelete(newValue.text, index);
                              return newValue;
                            } else if (newValue.text.length <= 1 && RegExp(r'[0-9]').hasMatch(newValue.text)) {
                              _handleCodeInput(newValue.text, index);
                              return newValue;
                            }
                            return oldValue;
                          },
                        ),
                      ],
                      decoration: InputDecoration(
                        counterText: '',
                        contentPadding: EdgeInsets.zero,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFB266FF), width: 2),
                        ),
                        filled: true,
                        fillColor: const Color(0xFF1E1E1E),
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          Button(
            text: 'Verificar',
            onPressed: () {
              final code = getCode();
              if (code.length == 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Código verificado: $code')),
                );
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Por favor ingresa el código completo')),
                );
              }
            },
          ),

          const SizedBox(height: 16),

          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Código reenviado a tu email')),
              );
            },
            child: const Text(
              'Reenviar código ahora',
              style: TextStyle(
                color: Color(0xFFB266FF),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
