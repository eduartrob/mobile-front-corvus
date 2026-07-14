import 'package:flutter/material.dart';
import 'package:mobile/l10n/app_localizations.dart';

class RoleSelector extends StatelessWidget {
  final String selectedRole;
  final ValueChanged<String> onRoleChanged;
  final bool showLabels;

  const RoleSelector({
    super.key,
    required this.selectedRole,
    required this.onRoleChanged,
    this.showLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final normalizedRole = selectedRole.toUpperCase();
    final isStudent = normalizedRole == 'ALUMNO';

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _RoleChip(
              icon: Icons.school_outlined,
              activeIcon: Icons.school,
              label: l10n.student,
              isSelected: isStudent,
              activeColor: colors.primary,
              onTap: () => onRoleChanged('ALUMNO'),
            ),
          ),
          Expanded(
            child: _RoleChip(
              icon: Icons.co_present_outlined,
              activeIcon: Icons.co_present,
              label: l10n.teacher,
              isSelected: !isStudent,
              activeColor: colors.tertiary,
              onTap: () => onRoleChanged('DOCENTE'),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;

  const _RoleChip({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: isSelected ? colors.surface : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: colors.shadow.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: Icon(
                    isSelected ? activeIcon : icon,
                    key: ValueKey<bool>(isSelected),
                    color: isSelected ? activeColor : colors.onSurfaceVariant,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? colors.onSurface : colors.onSurfaceVariant,
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
