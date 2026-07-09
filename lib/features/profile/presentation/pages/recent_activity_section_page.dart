import 'package:flutter/material.dart';
import 'package:mobile/features/profile/presentation/widgets/recent_activity_section.dart';

class RecentActivitySectionPage extends StatelessWidget {
  const RecentActivitySectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Actividad Reciente', style: TextStyle(color: colorScheme.onSurfaceVariant)),
        iconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        leadingWidth: 48,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: RecentActivitySection(),
      ),
    );
  }
}
