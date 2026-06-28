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

  static const int analysisNotificationId = 999;
  static const String analysisChannelId = 'corvus_analysis_channel';
  static const String analysisChannelName = 'Análisis de Propuestas';
  static const String analysisChannelDescription = 'Notificaciones sobre el análisis exhaustivo de proyectos';

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

  Future<void> showProgressNotification({
    required int progress,
    required int maxProgress,
    required String title,
    required String message,
  }) async {
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
      subText: message, // FORZAR que el mensaje se muestre en OPPO/Xiaomi
    );

    final NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);

    await _flutterLocalNotificationsPlugin.show(
      syncNotificationId,
      title,
      message,
      notificationDetails,
    );
  }

  Future<void> showIndeterminateProgressNotification({required String title, required String message}) async {
    final AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      channelShowBadge: false,
      importance: Importance.max,
      priority: Priority.high,
      onlyAlertOnce: true,
      showProgress: true,
      indeterminate: true,
      icon: '@mipmap/ic_launcher',
      ongoing: true,
      subText: message,
    );

    final NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);

    await _flutterLocalNotificationsPlugin.show(
      syncNotificationId,
      title,
      message,
      notificationDetails,
    );
  }

  Future<void> showResultNotification(String title, String message) async {
    final AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      timeoutAfter: 6000,
    );

    final NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);

    await _flutterLocalNotificationsPlugin.cancel(syncNotificationId);

    await _flutterLocalNotificationsPlugin.show(
      syncNotificationId + 2,
      title,
      message,
      notificationDetails,
    );
  }

  Future<void> showSuccessNotification({
    required String title,
    required String message,
  }) async {
    final AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      timeoutAfter: 6000, // Desaparece sola a los 6 segundos
    );

    final NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);

    // Cancelar la barra de progreso
    await _flutterLocalNotificationsPlugin.cancel(syncNotificationId);

    // Mostrar el éxito con un ID diferente para que se quede un rato
    await _flutterLocalNotificationsPlugin.show(
      syncNotificationId + 1,
      title,
      message,
      notificationDetails,
    );
  }

  Future<void> cancelSyncNotification() async {
    await _flutterLocalNotificationsPlugin.cancel(syncNotificationId);
  }

  // ─── Métodos para el Análisis Exhaustivo ───

  Future<void> showAnalysisProgressNotification({
    required String title,
    required String message,
    required String phase,
  }) async {
    final AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      analysisChannelId,
      analysisChannelName,
      channelDescription: analysisChannelDescription,
      channelShowBadge: false,
      importance: Importance.low, // Low importance para no interrumpir al usuario repetidamente
      priority: Priority.low,
      onlyAlertOnce: true,
      showProgress: true,
      indeterminate: true,
      icon: '@mipmap/ic_launcher',
      ongoing: true, // Persistente
      subText: phase,
    );

    final NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);

    await _flutterLocalNotificationsPlugin.show(
      analysisNotificationId,
      title,
      message,
      notificationDetails,
    );
  }

  Future<void> showAnalysisCompleteNotification({
    required String title,
    required String message,
  }) async {
    final AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      analysisChannelId,
      analysisChannelName,
      channelDescription: analysisChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      timeoutAfter: 10000, // Desaparece sola a los 10 segundos
    );

    final NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);

    // Cancelar la barra de progreso persistente
    await _flutterLocalNotificationsPlugin.cancel(analysisNotificationId);

    // Mostrar el éxito con un ID diferente
    await _flutterLocalNotificationsPlugin.show(
      analysisNotificationId + 1,
      title,
      message,
      notificationDetails,
    );
  }

  Future<void> cancelAnalysisNotification() async {
    await _flutterLocalNotificationsPlugin.cancel(analysisNotificationId);
  }
}
