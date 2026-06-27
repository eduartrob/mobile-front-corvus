import 'package:flutter/material.dart';
import 'package:mobile/l10n/app_localizations.dart';

class FloatingAiInput extends StatefulWidget {
  final bool isVisible;
  final VoidCallback? onExpand;

  const FloatingAiInput({super.key, required this.isVisible, this.onExpand});

  @override
  State<FloatingAiInput> createState() => _FloatingAiInputState();
}

class _FloatingAiInputState extends State<FloatingAiInput> {
  bool _isMinimized = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    // We make sure it doesn't hide if it's minimized
    final bool shouldShow = widget.isVisible || _isMinimized;

    return AnimatedSlide(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      offset: shouldShow ? Offset.zero : const Offset(0, 0.2),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: shouldShow ? 1.0 : 0.0,
        child: IgnorePointer(
          ignoring: !shouldShow,
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOutCubic,
            alignment: _isMinimized ? Alignment.centerLeft : Alignment.bottomCenter,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return SizeTransition(
                  sizeFactor: animation,
                  axis: Axis.horizontal,
                  axisAlignment: -1.0,
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: _isMinimized
                  ? _buildMinimizedState(colorScheme)
                  : _buildExpandedState(colorScheme, l10n),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMinimizedState(ColorScheme colorScheme) {
    return GestureDetector(
      key: const ValueKey("minimized"),
      onTap: () {
        widget.onExpand?.call();
        setState(() {
          _isMinimized = false;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(left: 0, bottom: 24),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 24),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer.withValues(alpha: 0.9),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          border: Border.all(
            color: colorScheme.primary.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.1),
              blurRadius: 10,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Icon(
          Icons.auto_awesome,
          color: colorScheme.secondary,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildExpandedState(ColorScheme colorScheme, AppLocalizations l10n) {
    return Container(
      key: const ValueKey("expanded"),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.surfaceContainer.withValues(alpha: 0.9),
            colorScheme.surface.withValues(alpha: 0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: colorScheme.secondary,
                    size: 18,
                  ),
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
                onTap: () {
                  // Cerrar el teclado si está abierto
                  FocusScope.of(context).unfocus();
                  setState(() {
                    _isMinimized = true;
                  });
                },
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(
                    Icons.close,
                    color: colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.lookingForSomethingDifferent,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.lookingForSomethingDifferentDesc,
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: l10n.searchPlaceholder,
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.send,
                        color: colorScheme.onPrimary,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
