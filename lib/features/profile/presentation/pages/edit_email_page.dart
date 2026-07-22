import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/features/profile/presentation/provider/profile_provider.dart';
import 'package:mobile/core/error/error_handler.dart';
import 'package:mobile/core/error/app_exception.dart';

class EditEmailPage extends StatefulWidget {
  const EditEmailPage({super.key});

  @override
  State<EditEmailPage> createState() => _EditEmailPageState();
}

class _EditEmailPageState extends State<EditEmailPage> {
  late TextEditingController _primaryController;
  late TextEditingController _secondaryController;

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileProvider>().profile;
    _primaryController = TextEditingController(text: profile?.correo ?? '');
    _secondaryController = TextEditingController(text: profile?.correoSecundario ?? '');
  }

  @override
  void dispose() {
    _primaryController.dispose();
    _secondaryController.dispose();
    super.dispose();
  }

  void _showVerifyCodeDialog(String type) {
    final codeController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        bool isVerifying = false;
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Ingresa el código'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Hemos enviado un código PIN a tu correo. Ingrésalo a continuación:'),
                  const SizedBox(height: 16),
                  TextField(
                    controller: codeController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Ej. 123456',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isVerifying ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: isVerifying ? null : () async {
                    setStateDialog(() => isVerifying = true);
                    final provider = Provider.of<ProfileProvider>(context, listen: false);
                    try {
                      await provider.confirmVerificationCode(codeController.text.trim(), type);
                      if (!mounted) return;
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Correo verificado exitosamente'), backgroundColor: Colors.green),
                      );
                    } catch (e, st) {
                      setStateDialog(() => isVerifying = false);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(mapErrorToMessage(e)), backgroundColor: Colors.red),
                      );
                    }
                  },
                  child: isVerifying
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Verificar'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  void _requestVerify(String type) async {
    final provider = Provider.of<ProfileProvider>(context, listen: false);
    try {
      await provider.requestVerificationCode(type);
      if (!mounted) return;
      _showVerifyCodeDialog(type);
    } catch (e, st) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mapErrorToMessage(e)), backgroundColor: Colors.red),
      );
    }
  }

  void _addSecondaryEmail() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        bool isAdding = false;
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Añadir Correo Secundario'),
              content: TextField(
                controller: controller,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'ejemplo@correo.com',
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isAdding ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: isAdding ? null : () async {
                    if (controller.text.isEmpty || !controller.text.contains('@')) return;
                    setStateDialog(() => isAdding = true);
                    final provider = Provider.of<ProfileProvider>(context, listen: false);
                    try {
                      await provider.addSecondaryEmail(controller.text.trim());
                      if (!mounted) return;
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Correo añadido. Recuerda verificarlo.'), backgroundColor: Colors.green),
                      );
                    } catch (e, st) {
                      setStateDialog(() => isAdding = false);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(mapErrorToMessage(e)), backgroundColor: Colors.red),
                      );
                    }
                  },
                  child: isAdding
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Añadir'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  void _deleteEmail(String type) async {
    final provider = Provider.of<ProfileProvider>(context, listen: false);
    try {
      await provider.deleteEmail(type);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Correo borrado exitosamente'), backgroundColor: Colors.green),
      );
    } catch (e, st) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mapErrorToMessage(e)), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;
    final colorScheme = Theme.of(context).colorScheme;

    if (profile == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    _primaryController.text = profile.correo ?? '';
    _secondaryController.text = profile.correoSecundario ?? '';

    final bool hasSecondary = profile.correoSecundario != null && profile.correoSecundario!.isNotEmpty;
    final bool canDelete = hasSecondary; // Puede borrar uno si hay dos
    
    final bool isPrimaryGoogle = profile.correo == profile.googleEmail && profile.googleEmail != null;
    final bool isSecondaryGoogle = profile.correoSecundario == profile.googleEmail && profile.googleEmail != null;

    final bool isPrimaryVerified = isPrimaryGoogle || profile.isVerified == true;
    final bool isSecondaryVerified = isSecondaryGoogle || profile.secondaryIsVerified == true;

    return Scaffold(
      appBar: AppBar(
        title: Text('Correo electrónico', style: TextStyle(color: colorScheme.onSurfaceVariant)),
        iconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        leadingWidth: 48,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isPrimaryGoogle ? 'Correo Electrónico Principal (Google)' : 'Correo Electrónico Principal',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _primaryController,
                      readOnly: true,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: colorScheme.primary, width: 2),
                        ),
                        suffixIcon: isPrimaryVerified 
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : PopupMenuButton<String>(
                          icon: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                          tooltip: 'Verificar Correo',
                          position: PopupMenuPosition.under,
                          elevation: 3,
                          color: colorScheme.surfaceContainerHigh,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              enabled: false,
                              child: Text(
                                'Tu correo no está verificado.',
                                style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'verify',
                              child: Row(
                                children: [
                                  Icon(Icons.mark_email_read, size: 20),
                                  SizedBox(width: 12),
                                  Text('Enviar código de verificación'),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'verify') {
                              _requestVerify('primary');
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  if (canDelete) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteEmail('primary'),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Este correo está ligado a tu cuenta y no puede ser modificado por seguridad.',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
              
              if (hasSecondary) ...[
                const SizedBox(height: 24),
                Text(
                  isSecondaryGoogle ? 'Correo Electrónico Secundario (Google)' : 'Correo Electrónico Secundario',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _secondaryController,
                        readOnly: true,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: colorScheme.primary, width: 2),
                          ),
                          suffixIcon: isSecondaryVerified 
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : PopupMenuButton<String>(
                          icon: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                          tooltip: 'Verificar Correo',
                          position: PopupMenuPosition.under,
                          elevation: 3,
                          color: colorScheme.surfaceContainerHigh,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              enabled: false,
                              child: Text(
                                'Tu correo no está verificado.',
                                style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'verify',
                              child: Row(
                                children: [
                                  Icon(Icons.mark_email_read, size: 20),
                                  SizedBox(width: 12),
                                  Text('Enviar código de verificación'),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'verify') {
                              _requestVerify('secondary');
                            }
                          },
                        ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteEmail('secondary'),
                    ),
                  ],
                ),
              ] else ...[
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: _addSecondaryEmail,
                  icon: const Icon(Icons.add),
                  label: const Text('Añadir Correo Secundario'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
