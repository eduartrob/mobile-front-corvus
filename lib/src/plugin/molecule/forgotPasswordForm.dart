import 'package:flutter/material.dart';
import 'package:mobile/src/plugin/atom/button.dart';

class ForgotPasswordForm extends StatefulWidget {
  const ForgotPasswordForm({super.key});

  @override
  State<ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> {
  final emailController = TextEditingController();
  String? emailError;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Recuperar Contraseña',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Introduce tu correo electrónico y te enviaremos las instrucciones para restablecer tu acceso.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 28),

          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Correo Electrónico',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: emailError != null ? Colors.redAccent : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: TextField(
              controller: emailController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                icon: Icon(Icons.mail, color: Colors.white),
                hintText: 'tu@email.com',
                hintStyle: TextStyle(color: Colors.white54),
                border: InputBorder.none,
              ),
              onChanged: (value) {
                if (emailError != null) {
                  setState(() {
                    emailError = null;
                  });
                }
              },
            ),
          ),
          if (emailError != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                emailError!,
                style: const TextStyle(color: Colors.redAccent, fontSize: 12),
              ),
            ),
          ],

          const SizedBox(height: 28),

          Button(
            text: 'Enviar Instrucciones',
            onPressed: () {
              final email = emailController.text.trim();
              if (email.isEmpty) {
                setState(() {
                  emailError = 'Por favor, ingresa tu correo electrónico';
                });
                return;
              }
              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!emailRegex.hasMatch(email)) {
                setState(() {
                  emailError = 'Por favor, ingresa un correo electrónico válido';
                });
                return;
              }

              setState(() {
                emailError = null;
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Código de verificación enviado a $email')),
              );

              // Navigate to verify identity page, passing the email
              Navigator.of(context).pushNamed('/verify-identity', arguments: email);
            },
          ),

          const SizedBox(height: 20),

          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.arrow_back, color: Colors.white70, size: 18),
                SizedBox(width: 8),
                Text(
                  'Volver al login',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
