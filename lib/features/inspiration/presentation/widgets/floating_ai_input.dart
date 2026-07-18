import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:provider/provider.dart';
import 'package:mobile/features/inspiration/presentation/provider/inspiration_provider.dart';

class FloatingAiInput extends StatefulWidget {
  final bool isVisible;
  final VoidCallback? onExpand;

  const FloatingAiInput({super.key, required this.isVisible, this.onExpand});

  @override
  State<FloatingAiInput> createState() => _FloatingAiInputState();
}

class _FloatingAiInputState extends State<FloatingAiInput>
    with SingleTickerProviderStateMixin {
  bool _isMinimized = false;
  bool _isInitialized = false;
  
  bool _isLoading = false;
  String? _ideaResult;
  final TextEditingController _textController = TextEditingController();
  
  late AnimationController _animController;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.6),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutQuint,
    ));
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isMinimized = prefs.getBool('floating_ai_minimized') ?? false;
      _isInitialized = true;
    });
    if (widget.isVisible || _isMinimized) {
      _animController.forward();
    }
  }

  @override
  void didUpdateWidget(FloatingAiInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !oldWidget.isVisible) {
      _animController.forward();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final bool shouldShow = widget.isVisible || _isMinimized;

    if (!shouldShow) return const SizedBox.shrink();

    return AnimatedAlign(
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOutCubic,
      alignment:
          _isMinimized ? Alignment.bottomLeft : Alignment.bottomCenter,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        switchInCurve: Curves.easeOutBack,
        switchOutCurve: Curves.easeInBack,
        layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
          return Stack(
            alignment: Alignment.bottomLeft,
            children: <Widget>[
              ...previousChildren,
              if (currentChild != null) currentChild,
            ],
          );
        },
        transitionBuilder: (Widget child, Animation<double> animation) {
          final scale = Tween<double>(begin: 0.2, end: 1.0).animate(animation);
          final slide = Tween<Offset>(
            begin: const Offset(0.0, 0.1),
            end: Offset.zero,
          ).animate(animation);

          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: slide,
              child: ScaleTransition(
                scale: scale,
                alignment: Alignment.bottomLeft,
                child: child,
              ),
            ),
          );
        },
        child: _isMinimized
            ? _buildMinimizedState(colorScheme)
            : _buildExpandedState(colorScheme, l10n),
      ),
    );
  }

  // ─── Minimized pill button ──────────────────────────────────────────────────
  Widget _buildMinimizedState(ColorScheme colorScheme) {
    const softBlue = Color(0xFF5B8DEF);
    const softBlueDark = Color(0xFF4A7DE0);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const ValueKey('minimized'),
        onTap: () async {
          widget.onExpand?.call();
          setState(() => _isMinimized = false);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('floating_ai_minimized', false);
        },
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        child: Container(
          margin: const EdgeInsets.only(left: 0, bottom: 28),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [softBlue, softBlueDark],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x595B8DEF),
                blurRadius: 18,
                spreadRadius: 0,
                offset: Offset(4, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.auto_awesome,
            color: Colors.white,
            size: 26,
          ),
        ),
      ),
    );
  }

  // ─── Expanded floating card ─────────────────────────────────────────────────
  Widget _buildExpandedState(ColorScheme colorScheme, AppLocalizations l10n) {
    return SlideTransition(
      position: _slideAnim,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                key: const ValueKey('expanded'),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF5B8DEF).withValues(alpha: 0.32),
                    const Color(0xFF4A7DE0).withValues(alpha: 0.26),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.55),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Header row ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF5B8DEF).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.auto_awesome,
                                color: Color(0xFF5B8DEF), size: 18),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            l10n.generateIdeas,
                            style: TextStyle(
                              color: colorScheme.onSurface.withValues(alpha: 0.85),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: () async {
                          FocusScope.of(context).unfocus();
                          setState(() => _isMinimized = true);
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('floating_ai_minimized', true);
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Icon(Icons.close,
                              color: colorScheme.onSurfaceVariant, size: 20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_ideaResult != null) ...[
                    // Result view
                    Text(
                      "¿Mejoramos tu idea?",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.45,
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          _ideaResult!,
                          style: TextStyle(fontSize: 14, color: colorScheme.onSurface),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _ideaResult = null;
                            _textController.clear();
                          });
                        },
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text("Consultar otra idea"),
                      ),
                    ),
                  ] else if (_isLoading) ...[
                    // Loading view
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.0),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    Center(
                      child: Text(
                        "Analizando reglas y proyectos similares...",
                        style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                  ] else ...[
                    // Default input view
                    Text(
                      l10n.lookingForSomethingDifferent,
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700, color: colorScheme.onSurface),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.lookingForSomethingDifferentDesc,
                      style: TextStyle(
                          fontSize: 13, color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 16),
                    // ── Search input ──
                    Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0),
                              child: TextField(
                                controller: _textController,
                                decoration: InputDecoration(
                                  hintText: l10n.searchPlaceholder,
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(
                                      color: colorScheme.onSurfaceVariant),
                                ),
                                style: TextStyle(fontSize: 14, color: colorScheme.onSurface),
                                onSubmitted: (_) => _submitIdea(context),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Material(
                              color: const Color(0xFF5B8DEF),
                              borderRadius: BorderRadius.circular(12),
                              child: InkWell(
                                onTap: () => _submitIdea(context),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.send,
                                      color: Colors.white, size: 18),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitIdea(BuildContext context) async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
    });

    final provider = context.read<InspirationProvider>();
    final result = await provider.validateIdea(text);
    
    if (mounted) {
      setState(() {
        _isLoading = false;
        _ideaResult = result;
      });
    }
  }
}