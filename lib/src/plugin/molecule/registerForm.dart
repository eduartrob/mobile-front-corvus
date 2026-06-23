import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/src/plugin/molecule/inputCompleted.dart';
import 'package:mobile/src/plugin/atom/button.dart';

enum Role { student, teacher }

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  Role selected = Role.student;
  bool checked = false;

  void select(Role r) => setState(() => selected = r);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Únete a la Revolución RAG',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tu conocimiento, amplificado por IA.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),

          // Role toggle (wrap to avoid overflow on narrow screens)
          Wrap(
            spacing: 12,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              GestureDetector(
                onTap: () => select(Role.student),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 220),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    decoration: BoxDecoration(
                      color: selected == Role.student ? const Color(0xFFB266FF) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: selected == Role.student ? const Color(0xFFB266FF) : const Color(0xFF2A2A2A)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset('assets/icons/user.svg', width: 18, height: 18, color: selected == Role.student ? Colors.white : Colors.white70),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text('Soy Estudiante', overflow: TextOverflow.ellipsis, style: TextStyle(color: selected == Role.student ? Colors.white : Colors.white70)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              GestureDetector(
                onTap: () => select(Role.teacher),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 220),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    decoration: BoxDecoration(
                      color: selected == Role.teacher ? const Color(0xFFB266FF) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: selected == Role.teacher ? const Color(0xFFB266FF) : const Color(0xFF2A2A2A)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset('assets/icons/guirrete.svg', width: 18, height: 18, color: selected == Role.teacher ? Colors.white : Colors.white70),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text('Soy Profesor', overflow: TextOverflow.ellipsis, style: TextStyle(color: selected == Role.teacher ? Colors.white : Colors.white70)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          const InputCompleted(
            label: 'Nombre Completo',
            hint: 'Ej: Julian Casablancas',
            icon: Icons.person,
          ),
          const SizedBox(height: 12),
          const InputCompleted(
            label: 'Email Universitario',
            hint: 'julian@uni.edu',
            icon: Icons.alternate_email,
          ),
          const SizedBox(height: 12),
          const InputCompleted(
            label: 'Contraseña',
            hint: '••••••••',
            icon: Icons.lock,
            obscure: true,
          ),

          const SizedBox(height: 12),
          Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => checked = !checked),
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: checked ? const Color(0xFFB266FF) : Colors.transparent,
                    border: Border.all(color: Colors.white54),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: checked ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Acepto los Términos de Servicio y la Política de Privacidad.',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Button(
            text: 'Crear Cuenta',
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/home');
            },
          ),

          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Text(
              '¿Ya tienes cuenta? iniciar sesión',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
