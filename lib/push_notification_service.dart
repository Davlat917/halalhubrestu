import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:halal_hub_resto/firebase_options.dart';
import 'package:halal_hub_resto/device_registration_service.dart';

@pragma('vm:entry-point')
Future<void> backgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    debugPrint('backgroundHandler:');
    debugPrint(message.data.toString());
    debugPrint(message.notification?.title ?? '');
  }
}

class PushNotificationService {
  static FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future<void> requestNotificationPermission() async {
    final NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    if (kDebugMode) {
      final AuthorizationStatus s = settings.authorizationStatus;
      if (s == AuthorizationStatus.authorized) {
        debugPrint('Notification permission: authorized');
      } else if (s == AuthorizationStatus.provisional) {
        debugPrint('Notification permission: provisional');
      } else {
        debugPrint('Notification permission: denied or not determined');
      }
    }
  }

  Future<String?> getDeviceToken() async {
    try {
      if (Platform.isIOS) {
        String? apnsToken = await messaging.getAPNSToken();
        if (apnsToken == null) {
          for (int i = 0; i < 3; i++) {
            await Future<void>.delayed(const Duration(seconds: 1));
            apnsToken = await messaging.getAPNSToken();
            if (apnsToken != null) break;
          }
        }
        if (apnsToken != null) {
          final String? token = await messaging.getToken();
          if (kDebugMode) {
            debugPrint('Device token: $token');
          }
          return token;
        } else {
          if (kDebugMode) {
            debugPrint('APNS token not available yet');
          }
          return null;
        }
      } else {
        final String? token = await messaging.getToken();
        if (kDebugMode) {
          debugPrint('Device token: $token');
        }
        return token;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting FCM token: $e');
      }
      return null;
    }
  }
}

class PushNotificationHelper {
  static String fcmToken = '';

  static Future<void> initialized() async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    if (Platform.isAndroid) {
      NotificationHelper.initialized();
    } else if (Platform.isIOS) {
      await FirebaseMessaging.instance.requestPermission();
    }
    FirebaseMessaging.onBackgroundMessage(backgroundHandler);

    FirebaseMessaging.instance.onTokenRefresh.listen((String newToken) {
      fcmToken = newToken;
      if (kDebugMode) {
        debugPrint('FCM token refreshed (onTokenRefresh): $fcmToken');
      }
      DeviceRegistrationService.syncDeviceToken(fcmToken);
    });

    final PushNotificationService service = PushNotificationService();
    await service.requestNotificationPermission();
    getDeviceTokenToSendNotification();

    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (kDebugMode) {
        debugPrint('FirebaseMessaging.getInitialMessage');
      }

      if (message != null) {
        if (kDebugMode) {
          debugPrint('Initial notification: ${message.data}');
          debugPrint(message.notification?.title ?? '');
        }
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        debugPrint('FirebaseMessaging.onMessage');
      }
      if (message.notification != null) {
        if (kDebugMode) {
          debugPrint(message.notification!.title);
          debugPrint(message.notification!.body);
          debugPrint('${message.data}');
        }

        if (Platform.isAndroid) {
          NotificationHelper.displayNotification(message);
        }
        if (Platform.isIOS) {
          NotificationHelper.displayNotification(message);
        }
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        debugPrint('FirebaseMessaging.onMessageOpenedApp');
      }
      if (message.notification != null) {
        if (kDebugMode) {
          debugPrint(message.notification!.title);
          debugPrint(message.notification!.body);
          debugPrint('${message.data}');
        }
      }
    });

    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  static Future<String> getDeviceTokenToSendNotification() async {
    // Retry getToken on iOS while APNS propagates.
    for (int attempt = 0; attempt < 5; attempt++) {
      try {
        fcmToken = (await FirebaseMessaging.instance.getToken()) ?? '';
        if (fcmToken.isNotEmpty) {
          if (kDebugMode) {
            debugPrint('FCM token: $fcmToken');
          }
          await DeviceRegistrationService.syncDeviceToken(fcmToken);
          return fcmToken;
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('FCM getToken attempt ${attempt + 1}/5 failed: $e');
        }
      }
      if (attempt < 4) {
        await Future<void>.delayed(const Duration(seconds: 3));
      }
    }
    if (kDebugMode) {
      debugPrint(
        'FCM token not obtained yet; push will work when onTokenRefresh fires.',
      );
    }
    return '';
  }
}

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static const String _androidNotificationIcon = 'ic_notification';

  /// Channel shown in Android system notification settings.
  static const String _androidChannelId = 'halalhub_restaurant_general';
  static const String _androidChannelName = 'HalalHub Restaurant';

  static void initialized() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(_androidNotificationIcon);

    flutterLocalNotificationsPlugin.initialize(
      settings: const InitializationSettings(android: initializationSettingsAndroid),
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        if (kDebugMode) {
          debugPrint(details.toString());
          debugPrint(
            details.notificationResponseType ==
                    NotificationResponseType.selectedNotification
                ? 'selectedNotification'
                : 'selectedNotificationAction',
          );
          debugPrint(details.payload ?? '');
        }
      },
      onDidReceiveBackgroundNotificationResponse: localBackgroundHandler,
    );
  }

  static Future<void> displayNotification(RemoteMessage message) async {
    try {
      final int id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      const NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannelId,
          _androidChannelName,
          importance: Importance.max,
          priority: Priority.high,
          icon: _androidNotificationIcon,
        ),
      );

      await flutterLocalNotificationsPlugin.show(
        id: id,
        title: message.notification!.title,
        body: message.notification!.body,
        notificationDetails: notificationDetails,
        payload: json.encode(message.data),
      );
    } on Exception catch (e) {
      if (kDebugMode) {
        debugPrint('$e');
      }
    }
  }
}

Future<void> localBackgroundHandler(NotificationResponse data) async {
  if (kDebugMode) {
    debugPrint(data.toString());
    debugPrint(
      data.notificationResponseType == NotificationResponseType.selectedNotification
          ? 'selectedNotification'
          : 'selectedNotificationAction',
    );
    debugPrint(data.payload ?? '');
  }
}
