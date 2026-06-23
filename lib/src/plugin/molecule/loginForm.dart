import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/src/plugin/molecule/inputCompleted.dart';
import 'package:mobile/src/plugin/atom/button.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          const Icon(Icons.school, size: 48, color: Color(0xFFB266FF)),
          const SizedBox(height: 8),
          const Text(
            'Corvus',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 28),

          const Text(
            'Bienvenido de nuevo',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 28),

          const InputCompleted(
            label: "Correo Electrónico",
            hint: "ejemplo@acaderag.com",
            icon: Icons.mail,
          ),
          const SizedBox(height: 18),

          const InputCompleted(
            label: "Contraseña",
            hint: "••••••••",
            icon: Icons.lock,
            obscure: true,
          ),

          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: GestureDetector(
                onTap: () {},
                child: const Text(
                  'Olvidé mi contraseña',
                  style: TextStyle(
                    color: Color(0xFFB266FF),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),

          Button(
            text: "Iniciar Sesión",
            onPressed: () {},
          ),

          const SizedBox(height: 24),

          const Row(
            children: [
              Expanded(child: Divider(color: Color(0xFF404040))),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'O continuar con',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ),
              Expanded(child: Divider(color: Color(0xFF404040))),
            ],
          ),

          const SizedBox(height: 18),

          Wrap(
            spacing: 12,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              GestureDetector(
                onTap: () {},
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 220),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF404040)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset('assets/icons/google.svg', width: 24, height: 24),
                        const SizedBox(width: 8),
                        Flexible(
                          child: const Text(
                            'Google',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              GestureDetector(
                onTap: () {},
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 220),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF404040)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset('assets/icons/github.svg', width: 24, height: 24),
                        const SizedBox(width: 8),
                        Flexible(
                          child: const Text(
                            'GitHub',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '¿No tienes una cuenta? ',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  'Crear cuenta',
                  style: TextStyle(
                    color: Color(0xFFB266FF),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
