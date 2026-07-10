import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/features/profile/presentation/provider/profile_provider.dart';
import 'package:mobile/features/auth/presentation/widgets/career_autocomplete_field.dart';

class ProfEditCareersPage extends StatefulWidget {
  final List<String> initialCareers;

  const ProfEditCareersPage({super.key, required this.initialCareers});

  @override
  State<ProfEditCareersPage> createState() => _ProfEditCareersPageState();
}

class _ProfEditCareersPageState extends State<ProfEditCareersPage> {
  late List<String> _selectedCareers;
  final TextEditingController _careerSearchController = TextEditingController();
  late TextEditingController _universityController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    final profile = Provider.of<ProfileProvider>(context, listen: false).profile;
    _universityController = TextEditingController(text: profile?.universidad ?? '');
    
    // Build unique list: main career first, then extra careers (skills)
    final allCareers = <String>{};
    if (profile?.carrera != null && profile!.carrera!.isNotEmpty) {
      allCareers.add(profile.carrera!);
    }
    for (final c in widget.initialCareers) {
      if (c.isNotEmpty) allCareers.add(c);
    }
    _selectedCareers = allCareers.toList();
  }

  @override
  void dispose() {
    _careerSearchController.dispose();
    _universityController.dispose();
    super.dispose();
  }

  void _addCareer(String career) {
    if (career.trim().isEmpty) return;
    if (!_selectedCareers.contains(career.trim())) {
      setState(() {
        _selectedCareers.add(career.trim());
      });
    }
    _careerSearchController.clear();
  }

  void _removeCareer(String career) {
    setState(() {
      _selectedCareers.remove(career);
    });
  }

  Future<void> _handleSave() async {
    if (_careerSearchController.text.trim().isNotEmpty) {
      if (!_selectedCareers.contains(_careerSearchController.text.trim())) {
        _selectedCareers.add(_careerSearchController.text.trim());
      }
    }
    
    setState(() => _isLoading = true);
    final provider = Provider.of<ProfileProvider>(context, listen: false);
    final profile = provider.profile;
    
    try {
      await provider.updateProfile(
        fullName: profile?.alumno ?? '',
        enrollmentId: profile?.matricula ?? '',
        semester: profile?.cuatrimestre ?? '',
        skills: [],
        careers: _selectedCareers,
      );
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Carreras', style: TextStyle(color: colors.onSurfaceVariant)),
        iconTheme: IconThemeData(color: colors.onSurfaceVariant),
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        leadingWidth: 48,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Añade o elimina las carreras que impartes:',
                      style: TextStyle(color: colors.onSurfaceVariant, fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                    CareerAutocompleteField(
                      controller: _careerSearchController,
                      universityController: _universityController,
                      onSelected: _addCareer,
                      isDark: isDark,
                      colors: colors,
                    ),
                    const SizedBox(height: 24),
                    if (_selectedCareers.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _selectedCareers.map((career) {
                          return Chip(
                            label: Text(career),
                            backgroundColor: colors.primaryContainer,
                            deleteIconColor: colors.onPrimaryContainer,
                            onDeleted: () => _removeCareer(career),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                top: 16.0,
                bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 16.0 : 32.0,
              ),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isLoading ? null : _handleSave,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Guardar', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
