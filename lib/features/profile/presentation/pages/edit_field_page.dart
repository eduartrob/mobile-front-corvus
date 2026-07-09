import 'package:flutter/material.dart';

class EditFieldPage extends StatefulWidget {
  final String title;
  final String label;
  final String initialValue;
  final String? description;
  final TextInputType keyboardType;
  final Future<void> Function(String) onSave;

  const EditFieldPage({
    super.key,
    required this.title,
    required this.label,
    required this.initialValue,
    this.description,
    this.keyboardType = TextInputType.text,
    required this.onSave,
  });

  @override
  State<EditFieldPage> createState() => _EditFieldPageState();
}

class _EditFieldPageState extends State<EditFieldPage> {
  late TextEditingController _controller;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _isLoading = true;
    });
    try {
      await widget.onSave(_controller.text.trim());
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e'), backgroundColor: Colors.red),
        );
      }
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
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: TextStyle(color: colorScheme.onSurfaceVariant)),
        iconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
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
                      widget.label,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _controller,
                      keyboardType: widget.keyboardType,
                      autofocus: true,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: colorScheme.primary, width: 2),
                        ),
                      ),
                    ),
                    if (widget.description != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        widget.description!,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    ],
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
