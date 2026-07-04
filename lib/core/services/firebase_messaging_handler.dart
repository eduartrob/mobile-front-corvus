import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mobile/core/services/notification_service.dart';
import 'package:mobile/firebase_options.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as flutter_secure_storage;
import 'package:mobile/features/notifications/data/notifications_local_data_source.dart';

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
  
  if (message.notification != null) {
    // Es una notificación push visible, la guardamos en SQLite
    await NotificationsLocalDataSource.insertNotification({
      'title': message.notification!.title ?? 'Nueva Notificación',
      'body': message.notification!.body ?? '',
      'type': data['type'] ?? 'info',
      'timestamp': DateTime.now().toIso8601String(),
      'isRead': 0,
    });
    
    // Mostrar visualmente la notificación en primer plano usando flutter_local_notifications
    NotificationService().showResultNotification(
      message.notification!.title ?? 'Nueva Notificación',
      message.notification!.body ?? '',
    );
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
      const storage = flutter_secure_storage.FlutterSecureStorage();
      await storage.delete(key: 'cached_prof_config');
      await storage.delete(key: 'etag_prof_config'); // Importante borrar el ETAG para forzar refresh
      await storage.delete(key: 'cached_cluster_stats');
      await storage.delete(key: 'etag_cluster_stats');
    } catch (e) {
      // Ignorar error
    }
  }
}
