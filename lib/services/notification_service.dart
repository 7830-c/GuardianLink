import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();
    
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification click here if needed
        print("Notification clicked: ${details.payload}");
      },
    );
  }

  Future<String?> getDeviceToken() async {
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      return await _fcm.getToken();
    }
    return null;
  }

  Future<void> sendNotification({
    required List<String> targetTokens,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    // In a real production app, you would send this to your backend (e.g. Firebase Cloud Function)
    // which then calls the FCM API. Sending directly from client is not recommended for security.
    print("ATTEMPTING TO SEND NOTIFICATION: '$title' to ${targetTokens.length} devices.");
    print("Payload: $data");
    
    // For demonstration, we're logging. In a real project, replace this with an HTTP call to your API.
  }

  static Future<void> showLocalAlert({required String title, required String body}) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'guardian_channel',
      'Guardian Alerts',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails details = NotificationDetails(android: androidDetails);
    await _localNotifications.show(0, title, body, details);
  }

  static void initializeForegroundListeners() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Foreground message received: ${message.notification?.title}");
      
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null) {
        _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'guardian_channel',
              'Guardian Alerts',
              importance: Importance.max,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
            iOS: DarwinNotificationDetails(),
          ),
          payload: message.data.toString(),
        );
      }
    });
  }

  @pragma('vm:entry-point')
  static Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    // This must be a top-level function or a static method
    print("Handling a background message: ${message.messageId}");
  }
}
