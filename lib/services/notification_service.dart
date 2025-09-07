import 'dart:io';
import 'package:app_settings/app_settings.dart';
import 'package:fan_react/main.dart';
import 'package:fan_react/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

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
    tz.initializeTimeZones();

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
        _handleNotificationTap(response.payload);
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
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
        // await AppSettings.openAppSettings(type: AppSettingsType.notification);
        _savePermissionStatus();
      }
      if (status.isGranted && isChecked) {
        _savePermissionStatus();
        _scheduleInactiveNotification();
      } else if (status.isDenied || status.isPermanentlyDenied && isChecked) {
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
          _savePermissionStatus();
          _scheduleInactiveNotification();
        }
      }
    }
  }

  Future<void> showNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'Fun React',
      'Fun React Notifications',
      channelDescription: 'Notifications for the Fun React app',
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
      'Miss the action?',
      'New matches are waiting for your reactions!',
      platformChannelSpecifics,
      payload: 'Navigate to Home screen',
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

  // Top-level function for background notification handling
  @pragma('vm:entry-point')
  static void notificationTapBackground(
      NotificationResponse notificationResponse) {
    debugPrint(
        'Notification tapped in background: ${notificationResponse.payload}');
    _handleNotificationTap(notificationResponse.payload);
  }

  // Centralized method to handle notification tap and navigation
  static void _handleNotificationTap(String? payload) {
    final navigator = Navigator.of(navigatorKey.currentContext!);
    if (navigator.mounted) {
      navigator.push(
        MaterialPageRoute(
          builder: (context) => HomeScreen(payload: payload ?? 'No data'),
        ),
      );
    } else {
      debugPrint('Navigator is not mounted, skipping navigation');
    }
  }

  // Schedule notification for inactive users (more than 3 days)
  Future<void> _scheduleInactiveNotification() async {
    final prefs = await SharedPreferences.getInstance();
    final lastLogin = prefs.getInt('lastLoginTime') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    const threeDaysInMillis = 3 * 24 * 60 * 60 * 1000;

    if (now - lastLogin > threeDaysInMillis) {
      await _cancelScheduledNotification();
      await _scheduleDailyNotification();
    }
  }

  // Schedule a daily notification at 10:00
  Future<void> _scheduleDailyNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'inactive_channel',
      'Inactive User Notifications',
      channelDescription: 'Notifications for inactive users',
      importance: Importance.max,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    final scheduleTime = tz.TZDateTime(
      tz.local,
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      10,
      0,
      0,
    ).add(const Duration(days: 1)); // Schedule for next 10:00

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      1,
      'Miss the action?',
      'New matches are waiting for your reactions!',
      scheduleTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'Navigate to Home screen',
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // Cancel any existing scheduled notification
  Future<void> _cancelScheduledNotification() async {
    await _flutterLocalNotificationsPlugin.cancel(1);
  }

  // Update last login time
  Future<void> updateLastLoginTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastLoginTime', DateTime.now().millisecondsSinceEpoch);
    await _scheduleInactiveNotification();
  }
}
