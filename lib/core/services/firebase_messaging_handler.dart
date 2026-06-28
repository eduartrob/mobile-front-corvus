import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mobile/core/services/notification_service.dart';
import 'package:mobile/firebase_options.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Inicialización básica para el background
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    handleFCMMessage(message);
  } catch (e) {
    // Ignorar si no está configurado
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
  }
}
