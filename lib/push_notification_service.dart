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
  debugPrint("backgroundHandler:");
  debugPrint(message.data.toString());
  debugPrint(message.notification?.title ?? "");
}

class PushNotificationService {
  static FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future<void> requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(alert: true, announcement: true, badge: true, carPlay: true, criticalAlert: true, provisional: true, sound: true);

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        debugPrint('user granted permission');
      }
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      if (kDebugMode) {
        debugPrint('user granted provisional permission');
      }
    } else {
      if (kDebugMode) {
        debugPrint('user denied permission');
      }
    }
  }

  Future<String?> getDeviceToken() async {
    try {
      if (Platform.isIOS) {
        String? apnsToken = await messaging.getAPNSToken();
        if (apnsToken == null) {
          for (int i = 0; i < 3; i++) {
            await Future.delayed(const Duration(seconds: 1));
            apnsToken = await messaging.getAPNSToken();
            if (apnsToken != null) break;
          }
        }
        if (apnsToken != null) {
          String? token = await messaging.getToken();
          if (kDebugMode) {
            debugPrint('Device token: $token');
          }
          return token;
        } else {
          if (kDebugMode) {
            debugPrint("APNS token hali ham mavjud emas");
          }
          return null;
        }
      } else {
        String? token = await messaging.getToken();
        if (kDebugMode) {
          debugPrint('Device token: $token');
        }
        return token;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Token olishda xato: $e");
      }
      return null;
    }
  }
}

class PushNotificationHelper {
  static String fcmToken = "";

  static Future<void> initialized() async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    if (Platform.isAndroid) {
      NotificationHelper.initialized();
    } else if (Platform.isIOS) {
      await FirebaseMessaging.instance.requestPermission();
    }
    FirebaseMessaging.onBackgroundMessage(backgroundHandler);

    // Token o'zgarganda avtomatik yangilash
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      fcmToken = newToken;
      debugPrint("FCM Token yangilandi (onTokenRefresh): $fcmToken");
      DeviceRegistrationService.syncDeviceToken(fcmToken);
    });

    final service = PushNotificationService();
    await service.requestNotificationPermission();
    getDeviceTokenToSendNotification();

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      debugPrint("FirebaseMessaging.instance.getInitialMessage");

      if (message != null) {
        debugPrint("New Notification");
        debugPrint(message.data.toString());
        debugPrint(message.notification?.title ?? "");
      }
    });

    FirebaseMessaging.onMessage.listen((message) {
      debugPrint("FirebaseMessaging.onMessage.listen");
      if (message.notification != null) {
        debugPrint(message.notification!.title);
        debugPrint(message.notification!.body);
        debugPrint("${message.data}");

        if (Platform.isAndroid) {
          NotificationHelper.displayNotification(message);
        }
        if (Platform.isIOS) {
          NotificationHelper.displayNotification(message);
        }
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint("FirebaseMessaging.onMessageOpenedApp.listen");
      if (message.notification != null) {
        debugPrint(message.notification!.title);
        debugPrint(message.notification!.body);
        debugPrint("${message.data}");
      }
    });

    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);
  }

  static Future<String> getDeviceTokenToSendNotification() async {
    // iOS da to'g'ridan-to'g'ri getToken() ni retry bilan chaqiramiz
    // getToken() o'zi ichki APNS tokenni kutadi
    for (int attempt = 0; attempt < 5; attempt++) {
      try {
        fcmToken = (await FirebaseMessaging.instance.getToken()) ?? "";
        if (fcmToken.isNotEmpty) {
          debugPrint("FCM Token: $fcmToken");
          await DeviceRegistrationService.syncDeviceToken(fcmToken);
          return fcmToken;
        }
      } catch (e) {
        debugPrint("FCM token olish urinish ${attempt + 1}/5 xato: $e");
      }
      // Keyingi urinishdan oldin kutamiz
      if (attempt < 4) {
        await Future.delayed(const Duration(seconds: 3));
      }
    }
    debugPrint("FCM token olinmadi. Push notification keyinroq ishga tushadi (onTokenRefresh orqali).");
    return "";
  }
}

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static const String _androidNotificationIcon = 'ic_notification';

  static void initialized() {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings(_androidNotificationIcon);

    flutterLocalNotificationsPlugin.initialize(
      settings: const InitializationSettings(android: initializationSettingsAndroid),
      onDidReceiveNotificationResponse: (details) {
        debugPrint(details.toString());
        debugPrint("localBackgroundHandler :");
        debugPrint(details.notificationResponseType == NotificationResponseType.selectedNotification ? "selectedNotification" : "selectedNotificationAction");
        debugPrint(details.payload);

        try {} catch (e) {
          debugPrint("$e");
        }
      },
      onDidReceiveBackgroundNotificationResponse: localBackgroundHandler,
    );
  }

  static void displayNotification(RemoteMessage message) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      const notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          "push_notification_demo",
          "push_notification_demo_channel",
          importance: Importance.max,
          priority: Priority.high,
          icon: _androidNotificationIcon,
        ),
      );

      await flutterLocalNotificationsPlugin.show(id: id, title: message.notification!.title, body: message.notification!.body, notificationDetails: notificationDetails, payload: json.encode(message.data));
    } on Exception catch (e) {
      debugPrint("$e");
    }
  }
}

Future<void> localBackgroundHandler(NotificationResponse data) async {
  debugPrint(data.toString());
  debugPrint("localBackgroundHandler :");
  debugPrint(data.notificationResponseType == NotificationResponseType.selectedNotification ? "selectedNotification" : "selectedNotificationAction");
  debugPrint(data.payload);

  try {} catch (e) {
    debugPrint("$e");
  }
}
