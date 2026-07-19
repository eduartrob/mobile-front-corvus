import 'package:mobile/core/network/api_endpoints.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../core/network/api_config.dart';

class UniversityAutocompleteField extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSelected;
  final bool isDark;
  final ColorScheme colors;

  const UniversityAutocompleteField({
    super.key,
    required this.controller,
    required this.onSelected,
    required this.isDark,
    required this.colors,
  });

  @override
  State<UniversityAutocompleteField> createState() => _UniversityAutocompleteFieldState();
}

class _UniversityAutocompleteFieldState extends State<UniversityAutocompleteField> {
  String _lastQuery = '';

  Future<List<String>> _getUniversities(String query) async {

    _lastQuery = query;
    await Future.delayed(const Duration(milliseconds: 300));
    if (_lastQuery != query) return [];

    try {
      final response = await http
          .get(Uri.parse('${ApiConfig.apiGatewayUrl}${ApiEndpoints.authUniversities}?search=$query'))
          .timeout(const Duration(seconds: 10));

      if (_lastQuery != query) return [];

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((u) => u['name'].toString()).toList();
      }
    } catch (e) {
      debugPrint("Error fetching universities: $e");
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      initialValue: TextEditingValue(text: widget.controller.text),
      optionsViewOpenDirection: OptionsViewOpenDirection.up,
      optionsBuilder: (TextEditingValue textEditingValue) async {
        return await _getUniversities(textEditingValue.text);
      },
      onSelected: (String selection) {
        widget.controller.text = selection;
        widget.onSelected(selection);
      },
      fieldViewBuilder: (context, textEditingController, focusNode, onEditingComplete) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (textEditingController.text != widget.controller.text) {
            widget.controller.text = textEditingController.text;
          }
        });

        return ListenableBuilder(
          listenable: focusNode,
          builder: (context, child) {
            final hasFocus = focusNode.hasFocus;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: widget.isDark ? widget.colors.surfaceContainer : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hasFocus
                      ? widget.colors.primary
                      : (widget.isDark
                          ? widget.colors.outlineVariant.withValues(alpha: 0.5)
                          : const Color(0xFFE2E8F0)),
                  width: hasFocus ? 1.5 : 1.0,
                ),
              ),
              child: TextField(
                controller: textEditingController,
                focusNode: focusNode,
                onEditingComplete: () {
                  widget.controller.text = textEditingController.text;
                  onEditingComplete();
                },
                onChanged: (val) {
                  widget.controller.text = val;
                },
                style: TextStyle(
                  color: widget.colors.onSurface,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: "Ej. Universidad Nacional...",
                  hintStyle: TextStyle(
                    color: widget.colors.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                  border: InputBorder.none,
                  icon: const Icon(
                    Icons.account_balance,
                    color: Colors.deepPurpleAccent,
                    size: 20,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.arrow_drop_down),
                    onPressed: () {
                      if (textEditingController.text.isEmpty) {
                        textEditingController.text = ' ';
                        textEditingController.text = '';
                      }
                      focusNode.requestFocus();
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        final scrollController = ScrollController();
        return Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Material(
              elevation: 4.0,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
                bottom: Radius.zero,
              ),
              child: Container(
                width: MediaQuery.of(context).size.width - 64,
                constraints: const BoxConstraints(maxHeight: 250),
                decoration: BoxDecoration(
                  color: widget.isDark ? widget.colors.surfaceContainerHigh : Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                    bottom: Radius.zero,
                  ),
                ),
                child: Scrollbar(
                  controller: scrollController,
                  child: ListView.builder(
                    controller: scrollController,
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
                    physics: const ClampingScrollPhysics(),
                  itemCount: options.length,
                  itemBuilder: (BuildContext context, int index) {
                    final String option = options.elementAt(index);
                    return InkWell(
                      onTap: () {
                        onSelected(option);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          option,
                          style: TextStyle(
                            color: widget.colors.onSurface,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          ),
        );
      },
    );
  }
}
