import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Request permission (works on both web and mobile)
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('Permission status: ${settings.authorizationStatus}');

    // Initialize local notifications (Android only — not needed on web)
    if (!kIsWeb) {
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const InitializationSettings initSettings =
          InitializationSettings(android: androidSettings);
      await _localNotifications.initialize(settings: initSettings);
    }

    // For web, you need the VAPID key from Firebase Console
    // Console → Project Settings → Cloud Messaging → Web Push certificates
    if (kIsWeb) {
      await _messaging.getToken(
        vapidKey: 'BIm5hy8m_tj9cc0p_xIcDJwHFRE73wQyxSW1sEnYN1ctUlM9i_IKKAQaQCfKWTNpoX3G3-aevOE5TIp6QcdIkPY',
      );
    }

    // Get and print FCM token (useful for testing)
    String? token = await _messaging.getToken();
    print('FCM Token: $token');

    // Subscribe to topic
    // Note: topic messaging on web requires token-based sending instead
    if (!kIsWeb) {
      await _messaging.subscribeToTopic('flood_alerts');
    }

    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground message: ${message.notification?.title}');
      if (!kIsWeb) {
        _showLocalNotification(message);
      }
      // On web, Firebase shows it automatically if app is in background,
      // but foreground needs manual handling (e.g. a snackbar or dialog)
    });

    // Notification tap handler
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification tapped: ${message.data}');
      // Navigate to alerts page
    });
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'flood_alerts_channel',
      'Flood Alerts',
      channelDescription: 'Critical flood alert notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      id: message.hashCode,
      title: message.notification?.title ?? 'Flood Alert',
      body: message.notification?.body ?? 'Check the app for details',
      notificationDetails: notificationDetails,
    );
  }

  Future<void> subscribeToLocation(String location) async {
    if (!kIsWeb) {
      await _messaging.subscribeToTopic('flood_${location.toLowerCase()}');
    }
  }

  Future<void> unsubscribeFromLocation(String location) async {
    if (!kIsWeb) {
      await _messaging.unsubscribeFromTopic('flood_${location.toLowerCase()}');
    }
  }
}