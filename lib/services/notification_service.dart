import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      // Initialize timezone
      tz.initializeTimeZones();

      String timeZoneName = 'UTC';
      try {
        final dynamic localTimezone = await FlutterTimezone.getLocalTimezone();
        final String rawTimezone = localTimezone.toString();

        print(
          "Timezone type: ${localTimezone.runtimeType}, value: $rawTimezone",
        );

        if (localTimezone is String) {
          timeZoneName = localTimezone;
        } else {
          // Handle TimezoneInfo object (TimezoneInfo(id=Asia/Kolkata, ...))
          final idMatch = RegExp(r'id=([^,)]+)').firstMatch(rawTimezone);
          if (idMatch != null) {
            timeZoneName = idMatch.group(1) ?? 'UTC';
          } else {
            print("⚠️ Could not parse timezone ID from: $rawTimezone");
            timeZoneName = 'UTC';
          }
        }
      } catch (e) {
        print("⚠️ Error getting local timezone: $e");
        timeZoneName = 'UTC';
      }

      try {
        tz.setLocalLocation(tz.getLocation(timeZoneName));
      } catch (e) {
        print(
          "⚠️ Error setting location 'timeZoneName', falling back to UTC: $e",
        );
        try {
          tz.setLocalLocation(tz.getLocation('UTC'));
        } catch (e) {
          print("⚠️ CRITICAL: Could not even set UTC: $e");
          // Depending on timezone package version, 'UTC' should exist in default data
        }
      }

      // Android initialization
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization
      const DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );

      const InitializationSettings initializationSettings =
          InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsDarwin,
          );

      await flutterLocalNotificationsPlugin.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: (
          NotificationResponse response,
        ) async {
          // Handle notification tap
        },
      );

      _isInitialized = true;
    } catch (e) {
      print("❌ CRITICAL ERROR in NotificationService.init: $e");
      // We do NOT set _isInitialized to true here, so we might retry or just fail gracefully
    }
  }

  Future<void> requestPermissions() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  Future<void> scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
  }) async {
    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: _nextInstanceOfTime(time),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_reminders',
            'Daily Study Reminders',
            channelDescription: 'Reminders to continue your photography course',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      print("⚠️ Error scheduling exact reminder: $e");
      print("🔄 Falling back to inexact scheduling...");
      try {
        await flutterLocalNotificationsPlugin.zonedSchedule(
          id: id,
          title: title,
          body: body,
          scheduledDate: _nextInstanceOfTime(time),
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              'daily_reminders',
              'Daily Study Reminders',
              channelDescription:
                  'Reminders to continue your photography course',
              importance: Importance.high,
              priority: Priority.high,
            ),
            iOS: DarwinNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      } catch (e2) {
        print("❌ Error scheduling inexact reminder: $e2");
      }
    }
  }

  Future<void> cancelReminder(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id: id);
  }

  Future<void> cancelAll() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> checkAndScheduleDefaultNotification() async {
    final pendingNotifications =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();

    // Check if we already have a reminder scheduled (ID 1 for daily reminder)
    final hasReminder = pendingNotifications.any((n) => n.id == 1);

    if (!hasReminder) {
      // Schedule default at 7 PM (19:00)
      await scheduleDailyReminder(
        id: 1,
        title: "Time to Learn!",
        body: "Continue your photography journey today.",
        time: const TimeOfDay(hour: 19, minute: 0),
      );
    }
  }

  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
