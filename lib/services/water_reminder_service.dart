// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';

/// Service for water reminder notifications
///
/// Dependencies needed in pubspec.yaml:
/// flutter_local_notifications: ^17.0.0
/// timezone: ^0.9.0
///
/// Platform Setup:
///
/// Android (android/app/src/main/AndroidManifest.xml):
/// <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
/// <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
///
/// iOS (ios/Runner/AppDelegate.swift):
/// Import UserNotifications and request permission
class WaterReminderService {
  // static final FlutterLocalNotificationsPlugin _notifications =
  //     FlutterLocalNotificationsPlugin();

  static const String _boxName = 'water_reminders';
  static const String _enabledKey = 'reminders_enabled';
  static const String _intervalKey = 'reminder_interval';
  static const String _startHourKey = 'start_hour';
  static const String _endHourKey = 'end_hour';

  /// Initialize notification service
  static Future<void> initialize() async {
    // NOTE: Uncomment when flutter_local_notifications is added to pubspec.yaml
    /*
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
        print('Notification tapped: ${details.payload}');
      },
    );

    // Request permissions (iOS)
    await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    // Request permissions (Android 13+)
    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    */

    // Load saved settings
    await _loadSettings();
  }

  /// Load reminder settings from Hive
  static Future<void> _loadSettings() async {
    final box = await Hive.openBox(_boxName);

    // Default settings
    if (!box.containsKey(_enabledKey)) {
      await box.put(_enabledKey, true);
    }
    if (!box.containsKey(_intervalKey)) {
      await box.put(_intervalKey, 60); // 60 minutes default
    }
    if (!box.containsKey(_startHourKey)) {
      await box.put(_startHourKey, 8); // 8 AM
    }
    if (!box.containsKey(_endHourKey)) {
      await box.put(_endHourKey, 22); // 10 PM
    }
  }

  /// Enable/disable reminders
  static Future<void> setRemindersEnabled(bool enabled) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_enabledKey, enabled);

    if (enabled) {
      await _scheduleReminders();
    } else {
      await _cancelAllReminders();
    }
  }

  /// Check if reminders are enabled
  static Future<bool> areRemindersEnabled() async {
    final box = await Hive.openBox(_boxName);
    return box.get(_enabledKey, defaultValue: true);
  }

  /// Set reminder interval (in minutes)
  static Future<void> setReminderInterval(int minutes) async {
    if (minutes < 15 || minutes > 240) {
      throw ArgumentError('Interval must be between 15-240 minutes');
    }

    final box = await Hive.openBox(_boxName);
    await box.put(_intervalKey, minutes);

    if (await areRemindersEnabled()) {
      await _scheduleReminders();
    }
  }

  /// Get reminder interval
  static Future<int> getReminderInterval() async {
    final box = await Hive.openBox(_boxName);
    return box.get(_intervalKey, defaultValue: 60);
  }

  /// Set reminder hours (start and end)
  static Future<void> setReminderHours(int startHour, int endHour) async {
    if (startHour < 0 || startHour > 23) {
      throw ArgumentError('Start hour must be 0-23');
    }
    if (endHour < 0 || endHour > 23) {
      throw ArgumentError('End hour must be 0-23');
    }
    if (endHour <= startHour) {
      throw ArgumentError('End hour must be after start hour');
    }

    final box = await Hive.openBox(_boxName);
    await box.put(_startHourKey, startHour);
    await box.put(_endHourKey, endHour);

    if (await areRemindersEnabled()) {
      await _scheduleReminders();
    }
  }

  /// Get reminder hours
  static Future<Map<String, int>> getReminderHours() async {
    final box = await Hive.openBox(_boxName);
    return {
      'start': box.get(_startHourKey, defaultValue: 8),
      'end': box.get(_endHourKey, defaultValue: 22),
    };
  }

  /// Schedule water reminders
  static Future<void> _scheduleReminders() async {
    // Cancel existing reminders first
    await _cancelAllReminders();

    final interval = await getReminderInterval();
    final hours = await getReminderHours();
    final startHour = hours['start']!;
    final endHour = hours['end']!;

    // NOTE: Uncomment when flutter_local_notifications is added
    /*
    final now = DateTime.now();
    var nextReminder = DateTime(
      now.year,
      now.month,
      now.day,
      startHour,
      0,
    );

    // If start time already passed, start tomorrow
    if (nextReminder.isBefore(now)) {
      nextReminder = nextReminder.add(const Duration(days: 1));
    }

    int notificationId = 1000;

    // Schedule reminders for the day
    while (nextReminder.hour < endHour) {
      await _scheduleNotification(
        id: notificationId++,
        title: '💧 Su İçme Zamanı!',
        body: 'Hidrate kalmayı unutma! Bir bardak su iç.',
        scheduledDate: nextReminder,
      );

      nextReminder = nextReminder.add(Duration(minutes: interval));
    }
    */

    print('Water reminders scheduled: ${interval}min interval, ${startHour}:00 - ${endHour}:00');
  }

  /// Schedule a single notification
  static Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    // NOTE: Uncomment when flutter_local_notifications is added
    /*
    final androidDetails = AndroidNotificationDetails(
      'water_reminders',
      'Su Hatırlatıcıları',
      channelDescription: 'Düzenli su içme hatırlatmaları',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      TZDateTime.from(scheduledDate, tz.local),
      details,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
    */
  }

  /// Cancel all reminders
  static Future<void> _cancelAllReminders() async {
    // NOTE: Uncomment when flutter_local_notifications is added
    // await _notifications.cancelAll();
    print('All water reminders cancelled');
  }

  /// Show immediate notification (for testing)
  static Future<void> showImmediateNotification({
    required String title,
    required String body,
  }) async {
    // NOTE: Uncomment when flutter_local_notifications is added
    /*
    const androidDetails = AndroidNotificationDetails(
      'water_reminders',
      'Su Hatırlatıcıları',
      channelDescription: 'Düzenli su içme hatırlatmaları',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      0,
      title,
      body,
      details,
    );
    */

    print('Immediate notification: $title - $body');
  }

  /// Get reminder messages (randomized for variety)
  static List<String> get _reminderMessages => [
        'Hidrate kalmayı unutma! 💧',
        'Su içme zamanı! 🥤',
        'Bir bardak su iç! 💦',
        'Vücudun suya ihtiyacı var! 💙',
        'Su içmeyi unutma! 🌊',
        'Sağlıklı kal, su iç! ✨',
        'Enerjini yükselt, su iç! ⚡',
        'Cildin suya teşekkür edecek! 🌟',
      ];

  /// Get random reminder message
  static String getRandomMessage() {
    final now = DateTime.now();
    final index = now.minute % _reminderMessages.length;
    return _reminderMessages[index];
  }

  /// Preset reminder schedules
  static const Map<String, Map<String, dynamic>> presets = {
    'frequent': {
      'name': 'Sık (30dk)',
      'interval': 30,
      'start': 8,
      'end': 22,
    },
    'regular': {
      'name': 'Normal (1 saat)',
      'interval': 60,
      'start': 8,
      'end': 22,
    },
    'relaxed': {
      'name': 'Rahat (2 saat)',
      'interval': 120,
      'start': 9,
      'end': 21,
    },
    'work_hours': {
      'name': 'Çalışma Saatleri',
      'interval': 45,
      'start': 9,
      'end': 18,
    },
  };

  /// Apply preset
  static Future<void> applyPreset(String presetKey) async {
    final preset = presets[presetKey];
    if (preset == null) return;

    await setReminderInterval(preset['interval']);
    await setReminderHours(preset['start'], preset['end']);
  }

  /// Get statistics
  static Future<Map<String, dynamic>> getStatistics() async {
    final enabled = await areRemindersEnabled();
    final interval = await getReminderInterval();
    final hours = await getReminderHours();

    final activeHours = hours['end']! - hours['start']!;
    final remindersPerDay = (activeHours * 60 / interval).floor();

    return {
      'enabled': enabled,
      'interval': interval,
      'startHour': hours['start'],
      'endHour': hours['end'],
      'remindersPerDay': remindersPerDay,
    };
  }
}
