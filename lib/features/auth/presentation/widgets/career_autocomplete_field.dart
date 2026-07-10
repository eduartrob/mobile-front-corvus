import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../core/network/api_config.dart';

class CareerAutocompleteField extends StatefulWidget {
  final TextEditingController controller;
  final TextEditingController universityController;
  final Function(String) onSelected;
  final bool isDark;
  final ColorScheme colors;

  const CareerAutocompleteField({
    super.key,
    required this.controller,
    required this.universityController,
    required this.onSelected,
    required this.isDark,
    required this.colors,
  });

  @override
  State<CareerAutocompleteField> createState() => _CareerAutocompleteFieldState();
}

class _CareerAutocompleteFieldState extends State<CareerAutocompleteField> {
  String _lastQuery = '';
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<List<String>> _getCareers(String query) async {
    if (widget.universityController.text.trim().isEmpty) return [];
    _lastQuery = query;
    await Future.delayed(const Duration(milliseconds: 300));
    if (_lastQuery != query) return [];

    try {
      final universityName = Uri.encodeComponent(widget.universityController.text.trim());
      final response = await http
          .get(Uri.parse('${ApiConfig.apiGatewayUrl}/auth/careers?search=$query&universityId=$universityName'))
          .timeout(const Duration(seconds: 10));

      if (_lastQuery != query) return [];

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((c) => c['name'].toString()).toList();
      }
    } catch (e) {
      debugPrint("Error fetching careers: $e");
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      textEditingController: widget.controller,
      focusNode: _focusNode,
      optionsViewOpenDirection: OptionsViewOpenDirection.down,
      optionsBuilder: (TextEditingValue textEditingValue) async {
        return await _getCareers(textEditingValue.text);
      },
      onSelected: (String selection) {
        widget.onSelected(selection);
      },
      fieldViewBuilder: (context, textEditingController, focusNode, onEditingComplete) {
        return TapRegion(
          groupId: 'autocomplete_career',
          onTapOutside: (event) {
            if (focusNode.hasFocus) {
              focusNode.unfocus();
            }
          },
          child: ListenableBuilder(
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
                readOnly: true,
                onTap: () {
                  if (textEditingController.text.isEmpty) {
                    textEditingController.text = ' ';
                    textEditingController.text = '';
                  }
                  focusNode.requestFocus();
                },
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
                  hintText: "Ej. Ingeniería de Software",
                  hintStyle: TextStyle(
                    color: widget.colors.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                  border: InputBorder.none,
                  icon: const Icon(
                    Icons.school,
                    color: Colors.greenAccent,
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
        ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        final scrollController = ScrollController();
        return TapRegion(
          groupId: 'autocomplete_career',
          child: Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Material(
                elevation: 4.0,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.zero,
                  bottom: Radius.circular(12),
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width - 64,
                  constraints: const BoxConstraints(maxHeight: 250),
                  decoration: BoxDecoration(
                    color: widget.isDark ? widget.colors.surfaceContainerHigh : Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.zero,
                      bottom: Radius.circular(12),
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
          ),
        );
      },
    );
  }
}
