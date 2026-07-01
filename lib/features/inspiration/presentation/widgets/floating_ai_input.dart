import 'package:flutter/material.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

    return GestureDetector(
      key: const ValueKey('minimized'),
      onTap: () async {
        widget.onExpand?.call();
        setState(() => _isMinimized = false);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('floating_ai_minimized', false);
      },
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
              color: Color(0x595B8DEF), // softBlue ~35% opacity
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
    );
  }

  // ─── Expanded glass card ────────────────────────────────────────────────────
  Widget _buildExpandedState(ColorScheme colorScheme, AppLocalizations l10n) {
    return SlideTransition(
      position: _slideAnim,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: Container(
          key: const ValueKey('expanded'),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 24,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(20),
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
                            Icon(Icons.auto_awesome,
                                color: colorScheme.secondary, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              l10n.generateIdeas,
                              style: TextStyle(
                                color: colorScheme.secondary,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
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
                    Text(
                      l10n.lookingForSomethingDifferent,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
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
                        color: colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0),
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: l10n.searchPlaceholder,
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(
                                      color: colorScheme.onSurfaceVariant),
                                ),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                              onTap: () {
                                FocusScope.of(context).unfocus();
                                ScaffoldMessenger.of(context)
                                    .hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(l10n.featureUpcoming),
                                    behavior: SnackBarBehavior.floating,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.send,
                                    color: colorScheme.onPrimary, size: 18),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
  }
}

