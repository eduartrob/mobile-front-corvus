import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'activity_item_widget.dart';

class RecentActivitySection extends StatelessWidget {
  const RecentActivitySection({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Removed header
          const SizedBox(height: 12),
          ActivityItemWidget(
            icon: Icons.update,
            title: l10n.ragEngineUpdate,
            time: l10n.timeTwoHoursAgo,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(),
          ),
          ActivityItemWidget(
            icon: Icons.menu_book,
            title: l10n.readingCompleted,
            time: l10n.timeYesterday,
          ),
        ],
      ),
    );
  }
}
