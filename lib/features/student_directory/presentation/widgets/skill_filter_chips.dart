import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/student_directory_provider.dart';

class SkillFilterChips extends StatelessWidget {
  const SkillFilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final provider = context.watch<StudentDirectoryProvider>();
    final selectedSkill = provider.selectedSkill;
    final skills = provider.skills;

    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: skills.length,
        itemBuilder: (context, index) {
          final skill = skills[index];
          final isSelected = selectedSkill == skill;

          return Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: GestureDetector(
              onTap: () {
                provider.selectSkill(skill);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF1E40AF) : colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? Colors.transparent : colorScheme.outlineVariant.withValues(alpha: 0.6),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    skill,
                    style: TextStyle(
                      color: isSelected ? Colors.white : colorScheme.onSurface.withValues(alpha: 0.8),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
