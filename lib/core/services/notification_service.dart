import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/router/appRouter.dart';
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

  static const String analysisProgressChannelId = 'corvus_analysis_progress_channel';
  static const String analysisProgressChannelName = 'Progreso de Análisis';
  static const String analysisProgressChannelDescription = 'Notificaciones silenciosas sobre el progreso del análisis';

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const LinuxInitializationSettings initializationSettingsLinux = LinuxInitializationSettings(
      defaultActionName: 'Open notification',
    );
    
    // -# para ios y otras plataformas se configura aqui se omite por brevedad para centrarse en android
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      linux: initializationSettingsLinux,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final context = rootNavigatorKey.currentContext;
        if (context != null) {
          if (response.payload == 'TEAM_INVITE') {
            context.push('/teams?tab=1');
          } else {
            context.push('/notifications?highlightLatest=true');
          }
        }
      },
    );
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

  Future<void> showIndeterminateProgressNotification({required String title, required String message}) async {
    final AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      channelShowBadge: false,
      importance: Importance.low,
      priority: Priority.low,
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

  Future<void> showResultNotification(String title, String message, {String? payload}) async {
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
      payload: payload,
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
      timeoutAfter: 6000,
    );

    final NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);

    await _flutterLocalNotificationsPlugin.cancel(syncNotificationId);

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

  Future<void> showAnalysisProgressNotification({
    required String title,
    required String message,
    required String phase,
  }) async {
    final AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      analysisProgressChannelId,
      analysisProgressChannelName,
      channelDescription: analysisProgressChannelDescription,
      channelShowBadge: false,
      importance: Importance.low,
      priority: Priority.low,
      onlyAlertOnce: true,
      showProgress: true,
      indeterminate: true,
      icon: '@mipmap/ic_launcher',
      ongoing: true,
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
      timeoutAfter: 10000,
    );

    final NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);

    await _flutterLocalNotificationsPlugin.cancel(analysisNotificationId);

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
