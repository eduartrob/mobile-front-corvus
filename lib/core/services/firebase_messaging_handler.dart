import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mobile/core/services/notification_service.dart';
import 'package:mobile/firebase_options.dart';
import 'package:mobile/core/services/secure_storage_service.dart';
import 'package:mobile/features/notifications/data/notifications_local_data_source.dart';
import 'package:mobile/core/router/appRouter.dart';
import 'package:provider/provider.dart';
import 'package:mobile/features/notifications/presentation/provider/notifications_provider.dart';
import 'package:mobile/features/notifications/presentation/pages/notifications_page.dart';
import 'package:mobile/features/teams/presentation/provider/teams_provider.dart';
import 'package:mobile/features/my_project/presentation/provider/my_project_provider.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await handleFCMMessage(message);
  } catch (e) {
  }
}

Future<void> handleFCMMessage(RemoteMessage message) async {
  final data = message.data;
  
  final storage = SecureStorageService();
  final role = await storage.read(key: 'auth_role');

  if (message.notification != null) {
    // Guardar en SQLite (historial temporal o caché) con un ID generado para satisfacer el schema
    await NotificationsLocalDataSource.insertNotification({
      'id': 'temp_${DateTime.now().millisecondsSinceEpoch}',
      'title': message.notification!.title ?? 'Nueva Notificación',
      'body': message.notification!.body ?? '',
      'type': data['type'] ?? 'info',
      'timestamp': DateTime.now().toIso8601String(),
      'isRead': 0,
      'authorName': data['authorName'],
      'authorPhotoUrl': data['authorPhotoUrl'],
    });
    
    // Si la app está en foreground, disparar un refresco silencioso al backend
    final context = rootNavigatorKey.currentContext;
    if (context != null) {
      try {
        context.read<NotificationsProvider>().fetchNotifications(silent: true);
        
        // WhatsApp-like real-time reactive updates para Equipos
        if (data['type'] == 'team_request' || data['type'] == 'team_accept') {
          context.read<TeamsProvider>().fetchMyTeam();
          context.read<TeamsProvider>().fetchRequests();
          context.read<TeamsProvider>().fetchSuggestions();
        }
        
        if (data['type'] == 'CONFIG_UPDATED') {
          context.read<TeamsProvider>().fetchMyTeam();
          context.read<MyProjectProvider>().refreshConfig();
        }
      } catch(e) {
        debugPrint('Provider no disponible en context actual');
      }
    }
    
    // Omitir alerta flotante si es un PROFESOR viendo una actualización de config o si ya estamos en la página
    bool skipHeadsUp = false;
    if (data['type'] == 'CONFIG_UPDATED' && role == 'PROFESOR') {
      skipHeadsUp = true;
    }
    if (NotificationsPage.isOpen) {
      skipHeadsUp = true;
    }

    if (!skipHeadsUp) {
      NotificationService().showResultNotification(
        message.notification!.title ?? 'Nueva Notificación',
        message.notification!.body ?? '',
        payload: data['type'],
      );
    } else {
      debugPrint("Alerta visual flotante omitida (es profesor o la página de notificaciones está abierta).");
    }
  }

  if (data['type'] == 'sync_progress') {
    final progress = int.tryParse(data['progress']?.toString() ?? '0') ?? 0;
    final total = int.tryParse(data['total']?.toString() ?? '100') ?? 100;
    final msg = data['message'] ?? 'Procesando...';
    
    NotificationService().showProgressNotification(
      progress: progress, 
      maxProgress: total, 
      title: 'Sincronización de Archivos',
      message: msg
    );
  } else if (data['type'] == 'sync_complete') {
    NotificationService().showSuccessNotification(
      title: '¡Sincronización Completada!',
      message: data['message'] ?? 'Los archivos fueron vectorizados correctamente.'
    );
  } else if (data['type'] == 'CONFIG_UPDATED') {
    try {
      final storage = SecureStorageService();
      final allData = await storage.readAll();
      final keysToDelete = allData.keys.where((key) => 
        key.startsWith('cached_prof_config') || 
        key.startsWith('etag_prof_config') ||
        key.startsWith('cached_cluster_stats') ||
        key.startsWith('etag_cluster_stats')
      ).toList();
      
      for (final key in keysToDelete) {
        await storage.delete(key: key);
      }
    } catch (e) {
      // Ignorar error
    }
  }
}
