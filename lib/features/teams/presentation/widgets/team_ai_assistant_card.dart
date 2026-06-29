import 'package:flutter/material.dart';
import 'package:mobile/l10n/app_localizations.dart';

class TeamAiAssistantCard extends StatelessWidget {
  const TeamAiAssistantCard({super.key});

  void _showUpcomingFeature(BuildContext context, AppLocalizations l10n) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.featureUpcoming),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.surfaceContainerHigh.withValues(alpha: 0.8),
            colorScheme.surface.withValues(alpha: 0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.05),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: colorScheme.secondary, size: 24),
              const SizedBox(width: 8),
              const Text(
                'AI Assistant',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface,
                height: 1.5,
              ),
              children: [
                TextSpan(text: l10n.aiAssistantTeamSuggestionSpan1),
                TextSpan(text: l10n.aiAssistantTeamSuggestionSpan2, style: const TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: l10n.aiAssistantTeamSuggestionSpan3),
                TextSpan(text: l10n.aiAssistantTeamSuggestionSpan4, style: const TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: l10n.aiAssistantTeamSuggestionSpan5),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton.icon(
              onPressed: () => _showUpcomingFeature(context, l10n),
              icon: const Icon(Icons.arrow_forward, size: 18),
              label: Text(l10n.generateWorkPlan),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
