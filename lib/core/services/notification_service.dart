import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static const int syncNotificationId = 888;
  static const String channelId = 'corvus_sync_channel';
  static const String channelName = 'Sincronización de Corvus';
  static const String channelDescription = 'Notificaciones sobre la vectorización de PDFs en segundo plano';

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    // Para iOS y otras plataformas se configura aquí (se omite por brevedad para centrarse en Android)
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> requestPermission() async {
    final AndroidFlutterLocalNotificationsPlugin? androidPlatform = 
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    await androidPlatform?.requestNotificationsPermission();
  }

  Future<void> showProgressNotification({required int progress, required int maxProgress, String message = 'Procesando...'}) async {
    final AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      channelShowBadge: false,
      importance: Importance.max,
      priority: Priority.high,
      onlyAlertOnce: true,
      showProgress: true,
      maxProgress: maxProgress,
      progress: progress,
      icon: '@mipmap/ic_launcher',
      ongoing: true, // Hace que la notificación no se pueda descartar deslizándola
    );

    final NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);

    await _flutterLocalNotificationsPlugin.show(
      syncNotificationId,
      'Corvus Sync',
      message,
      notificationDetails,
    );
  }

  Future<void> showSuccessNotification(String message) async {
    final AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    final NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);

    // Cancelar la barra de progreso
    await _flutterLocalNotificationsPlugin.cancel(syncNotificationId);

    // Mostrar el éxito con un ID diferente para que se quede un rato
    await _flutterLocalNotificationsPlugin.show(
      syncNotificationId + 1,
      '¡Sincronización Completada!',
      message,
      notificationDetails,
    );
  }

  Future<void> cancelSyncNotification() async {
    await _flutterLocalNotificationsPlugin.cancel(syncNotificationId);
  }
}
