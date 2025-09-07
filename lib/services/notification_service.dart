import 'dart:io';
import 'package:app_settings/app_settings.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService _notificationService =
      NotificationService._internal();
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_cup');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      requestCriticalPermission: false,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Handle notification tap
      },
    );

    bool isChecked = await _loadPermissionStatus();

    if (Platform.isIOS) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);

      final status = await Permission.notification.request();
      if (!isChecked) {
        _savePermissionStatus();
        return;
      }

      if (isChecked) {
        await AppSettings.openAppSettings(type: AppSettingsType.notification);
        _savePermissionStatus();
      }
      if (status.isGranted && isChecked) {
        await AppSettings.openAppSettings(type: AppSettingsType.notification);
        _savePermissionStatus();
      } else if (status.isDenied || status.isPermanentlyDenied && isChecked) {
        await AppSettings.openAppSettings(type: AppSettingsType.notification);
        _savePermissionStatus();
      }
    } else if (Platform.isAndroid) {
      final androidPlugin = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        final bool? areEnabled = await androidPlugin.areNotificationsEnabled();
        if (areEnabled == null) {
          return;
        }
        if (!areEnabled && isChecked) {
          await AppSettings.openAppSettings(type: AppSettingsType.notification);
          _savePermissionStatus();
        } else if (!areEnabled && !isChecked) {
          await androidPlugin.requestNotificationsPermission();
          _savePermissionStatus();
        } else {
          await AppSettings.openAppSettings(type: AppSettingsType.notification);
          _savePermissionStatus();
        }
      }
    }
  }

  Future<void> showNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'clearance_card',
      'Calculator Notifications',
      channelDescription: 'Notifications for the Calculator app',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      0,
      'Calculator',
      'Let\'s calculate!',
      platformChannelSpecifics,
      payload: '',
    );
  }

  Future<void> _savePermissionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasCheckedNotificationPermission', true);
  }

  Future<bool> _loadPermissionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('hasCheckedNotificationPermission') ?? false;
  }
}
