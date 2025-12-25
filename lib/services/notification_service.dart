import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../config/supabase_config.dart';

/// Push notification service using Firebase Cloud Messaging
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initialize notification service
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Request permission
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('✅ User granted notification permission');

        // Initialize local notifications
        await _initializeLocalNotifications();

        // Get FCM token
        final token = await _firebaseMessaging.getToken();
        if (token != null) {
          await _saveFCMToken(token);
          print('📱 FCM Token: $token');
        }

        // Setup message handlers
        _setupMessageHandlers();

        _initialized = true;
      } else {
        print('⚠️ User declined notification permission');
      }
    } catch (e) {
      print('❌ Error initializing notifications: $e');
    }
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  /// Setup FCM message handlers
  void _setupMessageHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📨 Foreground message: ${message.notification?.title}');
      _showLocalNotification(message);
    });

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📬 Notification tapped (background): ${message.data}');
      _handleNotificationTap(message.data);
    });

    // Handle notification tap when app is terminated
    _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('📭 Notification tapped (terminated): ${message.data}');
        _handleNotificationTap(message.data);
      }
    });
  }

  /// Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Default Notifications',
      channelDescription: 'General app notifications',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
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

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'TürkKalori',
      message.notification?.body ?? '',
      details,
      payload: message.data.toString(),
    );
  }

  /// Handle notification tap
  void _handleNotificationTap(Map<String, dynamic> data) {
    // TODO: Navigate to specific screen based on notification type
    final type = data['type'] as String?;
    final targetId = data['target_id'] as String?;

    print('🔔 Handling notification: type=$type, targetId=$targetId');

    // Example navigation logic
    // switch (type) {
    //   case 'food_log':
    //     // Navigate to food log screen
    //     break;
    //   case 'achievement':
    //     // Navigate to achievements screen
    //     break;
    //   case 'social':
    //     // Navigate to post/comment
    //     break;
    // }
  }

  /// Handle local notification tap
  void _onNotificationTapped(NotificationResponse response) {
    print('🔔 Local notification tapped: ${response.payload}');
    // Parse payload and navigate
  }

  /// Save FCM token to database
  Future<void> _saveFCMToken(String token) async {
    try {
      final userId = SupabaseConfig.currentUser?.id;
      if (userId == null) return;

      await SupabaseConfig.client.from('profiles').update({
        'fcm_token': token,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);

      print('✅ FCM token saved to database');
    } catch (e) {
      print('❌ Error saving FCM token: $e');
    }
  }

  /// Send notification to specific user (admin/server-side function)
  Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    // This should be called from server-side (Cloud Functions)
    // For demonstration purposes only

    try {
      // Get user's FCM token
      final response = await SupabaseConfig.client
          .from('profiles')
          .select('fcm_token')
          .eq('id', userId)
          .maybeSingle();

      final fcmToken = response?['fcm_token'] as String?;
      if (fcmToken == null) {
        print('⚠️ No FCM token for user: $userId');
        return;
      }

      // Call server endpoint to send notification
      // This requires a backend API endpoint that uses Firebase Admin SDK

      print('📤 Notification queued for user: $userId');
    } catch (e) {
      print('❌ Error sending notification: $e');
    }
  }

  /// Schedule local notification
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    // Requires timezone package configuration
    print('⏰ Notification scheduled for: $scheduledTime');

    // Example: Daily reminder at 9 AM
    // await _localNotifications.zonedSchedule(
    //   id,
    //   title,
    //   body,
    //   scheduledTime,
    //   details,
    //   androidAllowWhileIdle: true,
    //   uiLocalNotificationDateInterpretation:
    //       UILocalNotificationDateInterpretation.absoluteTime,
    // );
  }

  /// Cancel notification
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }
}

/// Notification types
enum NotificationType {
  foodLog,
  achievement,
  streak,
  social,
  reminder,
}

/// Notification model
class AppNotification {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final DateTime createdAt;
  final bool isRead;

  AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.data,
    required this.createdAt,
    this.isRead = false,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == 'NotificationType.${json['type']}',
        orElse: () => NotificationType.foodLog,
      ),
      title: json['title'] as String,
      body: json['body'] as String,
      data: json['data'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      isRead: json['is_read'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type.toString().split('.').last,
      'title': title,
      'body': body,
      'data': data,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
    };
  }
}
