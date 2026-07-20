import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:mobile/features/projects/presentation/provider/project_provider.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';
import 'package:mobile/shared/widgets/corvus_top_bar.dart';
import 'package:mobile/shared/widgets/corvus_button.dart';
import 'package:mobile/shared/widgets/corvus_input_completed.dart';
import 'package:mobile/features/projects/presentation/widgets/theme_picker.dart';
import 'package:mobile/l10n/app_localizations.dart';

class ProfCreateProjectPage extends StatefulWidget {
  const ProfCreateProjectPage({super.key});

  @override
  State<ProfCreateProjectPage> createState() => _ProfCreateProjectPageState();
}

class _ProfCreateProjectPageState extends State<ProfCreateProjectPage> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _teamSizeController = TextEditingController(text: '4');
  
  Color _selectedColor = ThemePicker.availableColors[0];
  String _selectedPattern = ThemePicker.availablePatterns[0];

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _teamSizeController.dispose();
    super.dispose();
  }

  void _createProject() async {
    final l10n = AppLocalizations.of(context)!;
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.nameRequired)),
      );
      return;
    }

    final token = context.read<AuthProvider>().currentUser?.token;
    if (token == null) return;

    final provider = context.read<ProjectProvider>();
    final success = await provider.createProject(
      name: name,
      description: _descController.text.trim(),
      teamSize: int.tryParse(_teamSizeController.text) ?? 4,
      token: token,
      themeColor: '#${_selectedColor.value.toRadixString(16).substring(2).toUpperCase()}',
      themePattern: _selectedPattern,
    );

    if (!mounted) return;

    if (success) {
      final newProject = provider.myProjects.firstWhere((p) => p['name'] == name, orElse: () => null);
      if (newProject != null) {
        _showSuccessDialog(newProject['code']);
      } else {
        context.pop();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? l10n.errorCreating)),
      );
    }
  }

  void _showSuccessDialog(String code) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final colors = Theme.of(context).colorScheme;
        return AlertDialog(
          title: Text(l10n.projectCreated, textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.shareCodeMessage,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
                ),
                child: Text(
                  code,
                  style: TextStyle(
                    fontSize: 28,
                    letterSpacing: 4,
                    fontWeight: FontWeight.w900,
                    color: colors.primary,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: code));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.codeCopied)),
                );
              },
              icon: const Icon(Icons.copy),
              label: Text(l10n.copy),
            ),
            FilledButton(
              onPressed: () {
                context.pop();
                context.pop();
              },
              child: Text(l10n.understood),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<ProjectProvider, bool>((p) => p.isLoading);
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: const CorvusTopBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.newProject,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.newProjectDesc,
              style: TextStyle(fontSize: 16, color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 32),
            InputCompleted(
              label: l10n.projectNameLabel,
              hint: l10n.projectNameHint,
              icon: Icons.school_outlined,
              controller: _nameController,
              iconColor: colors.primary,
            ),
            const SizedBox(height: 16),
            InputCompleted(
              label: l10n.descriptionOptional,
              hint: l10n.descriptionHint,
              icon: Icons.description_outlined,
              controller: _descController,
              iconColor: colors.primary,
            ),
            const SizedBox(height: 16),
            InputCompleted(
              label: l10n.maxTeamSize,
              hint: '4',
              icon: Icons.groups_outlined,
              controller: _teamSizeController,
              iconColor: colors.primary,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 32),
            ThemePicker(
              selectedColor: _selectedColor,
              selectedPattern: _selectedPattern,
              onColorChanged: (color) => setState(() => _selectedColor = color),
              onPatternChanged: (pattern) => setState(() => _selectedPattern = pattern),
            ),
            const SizedBox(height: 48),
            CorvusButton(
              text: isLoading ? l10n.creating : l10n.createProject,
              onPressed: isLoading ? () {} : _createProject,
            ),
          ],
        ),
      ),
    );
  }
}