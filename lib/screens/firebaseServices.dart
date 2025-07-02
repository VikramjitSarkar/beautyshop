import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class FirebaseService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Notification channel ID (must be consistent)
  static const String _channelId = 'high_importance_channel';
  static const String _channelName = 'High Importance Notifications';
  static const String _channelDesc = 'Used for important app notifications';

  /// Initialize all notification services
  static Future<void> initialize() async {
    await _setupLocalNotifications();
    await _requestNotificationPermissions();
    await _configureFirebaseMessaging();
  }

  /// Set up local notifications plugin
  static Future<void> _setupLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidSettings);

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
      },
    );

    // Create notification channel for Android 8.0+
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.high,
      playSound: true,
      showBadge: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  /// Request notification permissions
  static Future<void> _requestNotificationPermissions() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false, // For iOS - request directly without provisional
    );

    debugPrint('Notification permissions: ${settings.authorizationStatus}');
  }

  /// Configure Firebase Messaging handlers
  static Future<void> _configureFirebaseMessaging() async {
    // Get and print FCM token
    String? token = await _firebaseMessaging.getToken();
    debugPrint('FCM Token: $token');
    print("FCM TOKEN : $token");
    if (token != null) await sendToken(token);

    // Foreground message handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Foreground message received');
      _showNotification(message);
    });

    // Background/terminated message handler
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('App opened from notification');
      // Handle navigation when app is opened from notification
    });

    // Initial message when app is terminated
    RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('App launched from terminated state by notification');
      // Handle navigation
    }
  }

  /// Display local notification
  static Future<void> _showNotification(RemoteMessage message) async {
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          showWhen: true,
          icon: '@mipmap/ic_launcher',
        );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000, // Unique ID
      message.notification?.title ?? 'New Notification',
      message.notification?.body ?? '',
      notificationDetails,
      payload: jsonEncode(message.data),
    );
  }

  /// Send FCM token to your server
  static Future<void> sendToken(String token) async {
    // Implement your API call to send token to backend
    debugPrint('Sending FCM token to server: $token');
    // Example:
    // await http.post(
    //   Uri.parse('your-api-endpoint'),
    //   body: {'fcmToken': token},
    //   headers: {'Authorization': 'Bearer ${GlobalsVariables.token}'},
    // );
  }
}
