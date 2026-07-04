import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mobile/core/services/notification_service.dart';
import 'package:mobile/firebase_options.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as flutter_secure_storage;

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    handleFCMMessage(message);
  } catch (e) {
  }
}

void handleFCMMessage(RemoteMessage message) {
  final data = message.data;
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
    // Silent push to invalidate cache
    try {
      const storage = flutter_secure_storage.FlutterSecureStorage();
      storage.delete(key: 'cached_prof_config');
      storage.delete(key: 'cached_cluster_stats');
      // No mostramos notificación, es un evento silencioso para la UI
    } catch (e) {
      // Ignorar error
    }
  }
}
