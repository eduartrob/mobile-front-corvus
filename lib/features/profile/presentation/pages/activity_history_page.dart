import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/features/profile/presentation/provider/activity_history_provider.dart';
import 'package:mobile/features/prof_history/data/models/activity_log_model.dart';
import 'package:intl/intl.dart';
import '../widgets/activity_item_widget.dart';

class ActivityHistoryPage extends StatefulWidget {
  const ActivityHistoryPage({super.key});

  @override
  State<ActivityHistoryPage> createState() => _ActivityHistoryPageState();
}

class _ActivityHistoryPageState extends State<ActivityHistoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ActivityHistoryProvider>().fetchHistory();
    });
  }

  IconData _getIconForAction(String action) {
    switch (action) {
      case 'LOGIN':
        return Icons.login;
      case 'UPLOAD_DOCUMENT':
        return Icons.upload_file;
      case 'SYSTEM_ALERT':
        return Icons.warning;
      case 'VALIDATE_CLUSTER':
        return Icons.analytics;
      default:
        return Icons.history;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Historial de Actividad', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
      body: Consumer<ActivityHistoryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Text(
                'Error: ${provider.errorMessage}',
                style: TextStyle(color: colorScheme.error),
                textAlign: TextAlign.center,
              ),
            );
          }

          if (provider.history.isEmpty) {
            return const Center(
              child: Text('No hay actividad reciente para mostrar.'),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchHistory(),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              itemCount: provider.history.length,
              separatorBuilder: (context, index) => const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(),
              ),
              itemBuilder: (context, index) {
                final ActivityLogModel activity = provider.history[index];
                
                final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
                final dateStr = dateFormat.format(activity.createdAt.toLocal());

                return ActivityItemWidget(
                  icon: _getIconForAction(activity.action),
                  title: activity.detail,
                  time: dateStr,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
