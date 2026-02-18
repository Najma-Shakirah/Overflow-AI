import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Request permission
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('Permission status: ${settings.authorizationStatus}');

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground message: ${message.notification?.title}');
      _showLocalNotification(message);
    });

    // Handle notification taps
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification opened: ${message.data}');
      // Navigate to alert details page
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
      message.hashCode,
      message.notification?.title ?? 'Flood Alert',
      message.notification?.body ?? 'Check the app for details',
      notificationDetails,
    );
  }

  // Subscribe to location-specific alerts
  Future<void> subscribeToLocation(String location) async {
    await _messaging.subscribeToTopic('flood_${location.toLowerCase()}');
  }

  Future<void> unsubscribeFromLocation(String location) async {
    await _messaging.unsubscribeFromTopic('flood_${location.toLowerCase()}');
  }
}