import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Initialize notification plugin and configure timezone support
  static Future<void> init() async {
    tz.initializeTimeZones();
    try {
      // Set to Indian Standard Time (IST)
      tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
    } catch (e) {
      // Fallback in case location lookup fails
      if (kDebugMode) {
        print("Warning: Failed to set Asia/Kolkata timezone: $e");
      }
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Handle tapping notification if needed
      },
    );
  }

  /// Request permissions on Android 13+
  static Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        await androidImplementation.requestNotificationsPermission();
      }
    }
  }

  /// Schedule all enabled challenges and reminders based on user settings
  static Future<void> scheduleNotifications(int streakDays) async {
    // Clear existing schedules to prevent duplicate schedules
    await _notificationsPlugin.cancelAll();

    final prefs = await SharedPreferences.getInstance();
    final bool dailyEnabled = prefs.getBool('pref_notification_daily') ?? true;
    final bool streakEnabled = prefs.getBool('pref_notification_streak') ?? true;
    final bool weeklyEnabled = prefs.getBool('pref_notification_weekly') ?? true;
    final bool monthlyEnabled = prefs.getBool('pref_notification_monthly') ?? true;

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'bible_quiz_channel',
      'Bible Quiz Alerts',
      channelDescription: 'Daily reminders, streak warnings, weekly and monthly alerts',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

    final now = tz.TZDateTime.now(tz.local);

    // 1. Daily Challenge Reminder: Every day at 8:00 AM IST
    if (dailyEnabled) {
      var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 8, 0);
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }
      await _notificationsPlugin.zonedSchedule(
        id: 1,
        title: 'Daily Challenge',
        body: '📖 Don\'t forget your Daily Challenge! Earn bonus XP today.',
        scheduledDate: scheduledDate,
        notificationDetails: platformDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }

    // 2. Streak Warning: Every day at 6:00 PM IST (if has streak > 0)
    if (streakEnabled && streakDays > 0) {
      var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 18, 0);
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }
      await _notificationsPlugin.zonedSchedule(
        id: 2,
        title: 'Streak Alert',
        body: '⚠️ You\'re about to lose your $streakDays-day streak! Play now.',
        scheduledDate: scheduledDate,
        notificationDetails: platformDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }

    // 3. Weekly Challenge start: Every Saturday 8:00 PM IST
    if (weeklyEnabled) {
      var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 20, 0);
      while (scheduledDate.weekday != DateTime.saturday || scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }
      await _notificationsPlugin.zonedSchedule(
        id: 3,
        title: 'Weekly Challenge',
        body: '🏆 Weekly Challenge is now live! Can you top the leaderboard?',
        scheduledDate: scheduledDate,
        notificationDetails: platformDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }

    // 4. Monthly Challenge: First day of month at 9:00 AM IST
    if (monthlyEnabled) {
      var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, 1, 9, 0);
      if (scheduledDate.isBefore(now)) {
        int nextMonth = now.month == 12 ? 1 : now.month + 1;
        int nextYear = now.month == 12 ? now.year + 1 : now.year;
        scheduledDate = tz.TZDateTime(tz.local, nextYear, nextMonth, 1, 9, 0);
      }
      await _notificationsPlugin.zonedSchedule(
        id: 4,
        title: 'Monthly Challenge',
        body: '🎯 Monthly Challenge with 100 questions is ready! Earn 500 XP.',
        scheduledDate: scheduledDate,
        notificationDetails: platformDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
      );
    }
  }

  /// Cancel all notifications
  static Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }
}
