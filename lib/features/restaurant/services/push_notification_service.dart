import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:halalhub_restaurant/core/constants/constants.dart';
import 'package:halalhub_restaurant/core/di/injection.dart';
import 'package:halalhub_restaurant/core/services/vendor_notifications_ws_service.dart';

// ---------------------------------------------------------------------------
// Background handlers — top-level funksiyalar bo'lishi SHART (Firebase talab)
// ---------------------------------------------------------------------------

@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    debugPrint('[FCM] backgroundHandler: ${message.data}');
    debugPrint('[FCM] title: ${message.notification?.title}');
  }
}

@pragma('vm:entry-point')
Future<void> _localBackgroundHandler(NotificationResponse response) async {
  _logNotificationResponse('[LocalNotif][BG]', response);
}

void _logNotificationResponse(String tag, NotificationResponse response) {
  final type = response.notificationResponseType ==
          NotificationResponseType.selectedNotification
      ? 'selectedNotification'
      : 'selectedNotificationAction';
  if (kDebugMode) debugPrint('$tag type=$type | payload=${response.payload}');
}

// ---------------------------------------------------------------------------
// LocalNotificationService
// ---------------------------------------------------------------------------

class LocalNotificationService {
  LocalNotificationService._();

  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // ✅ FIX 1: 'settings:' named parameter
    await _plugin.initialize(
      settings: const InitializationSettings(android: androidSettings),
      onDidReceiveNotificationResponse: (response) {
        _logNotificationResponse('[LocalNotif][FG]', response);
      },
      onDidReceiveBackgroundNotificationResponse: _localBackgroundHandler,
    );
  }

  static Future<void> show(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    try {
      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          'halalhub_channel',
          'HalalHub Notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      );

      // ✅ FIX 2: show() positional arguments — id, title, body, notificationDetails
      await _plugin.show(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: notification.title,
        body: notification.body,
        notificationDetails: details,
        payload: jsonEncode(message.data),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('[LocalNotif] show error: $e');
    }
  }
}

// ---------------------------------------------------------------------------
// PushNotificationService  (FCM token + permission)
// ---------------------------------------------------------------------------

class PushNotificationService {
  PushNotificationService._();

  static const _tag = '[FCM]';
  static const _maxApnsRetries = 12;
  static const _maxTokenRetries = 5;
  static const _retryDelay = Duration(seconds: 1);

  static bool _initialized = false;
  static String _lastSentToken = '';

  static String fcmToken = '';

  static void _log(String msg) {
    if (kDebugMode) debugPrint('$_tag $msg');
  }

  // -------------------------------------------------------------------------
  // Public API
  // -------------------------------------------------------------------------

  static Future<void> initialize() async {
    if (_initialized) {
      _log('already initialized — skip');
      return;
    }
    _initialized = true;
    _log('initialize started | platform=${Platform.operatingSystem}');

    await _ensureFirebase();
    await _configurePlatform();

    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
    _log('background handler registered');

    FirebaseMessaging.instance.onTokenRefresh.listen(_onTokenRefresh);
    _log('onTokenRefresh listener registered');

    unawaited(_fetchAndSendToken());

    _listenMessages();

    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: true,
      sound: false,
    );
  }

  // -------------------------------------------------------------------------
  // Private helpers
  // -------------------------------------------------------------------------

  static Future<void> _ensureFirebase() async {
    if (Firebase.apps.isEmpty) {
      _log('Firebase not found — initializing...');
      await Firebase.initializeApp();
      _log('Firebase initialized');
    } else {
      _log('Firebase already initialized');
    }
  }

  static Future<void> _configurePlatform() async {
    if (Platform.isAndroid) {
      await LocalNotificationService.initialize();
      _log('Android local notification initialized');
    } else if (Platform.isIOS) {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        announcement: true,
        carPlay: true,
        criticalAlert: false,
        provisional: true,
      );
      _log('iOS permission: ${settings.authorizationStatus.name}');
    }
  }

  static void _onTokenRefresh(String newToken) {
    fcmToken = newToken;
    _log('token refreshed (len=${newToken.length})');
    _sendTokenToBackend(newToken);
  }

  static Future<void> _fetchAndSendToken() async {
    if (Platform.isIOS && !await _waitForApns()) {
      _log('APNS not ready — FCM token request skipped');
      return;
    }

    for (var attempt = 1; attempt <= _maxTokenRetries; attempt++) {
      try {
        _log('getToken attempt $attempt/$_maxTokenRetries');
        final token = await FirebaseMessaging.instance.getToken() ?? '';
        if (token.isNotEmpty) {
          fcmToken = token;
          _log('FCM token received (len=${token.length})');
          _sendTokenToBackend(token);
          return;
        }
        _log('empty token on attempt $attempt');
      } catch (e) {
        _log('getToken error on attempt $attempt: $e');
      }
      if (attempt < _maxTokenRetries) {
        await Future.delayed(_retryDelay * attempt);
      }
    }
    _log('FCM token not received after retries; waiting on onTokenRefresh');
  }

  static Future<bool> _waitForApns() async {
    for (var i = 1; i <= _maxApnsRetries; i++) {
      try {
        final apns = await FirebaseMessaging.instance.getAPNSToken();
        if (apns != null && apns.trim().isNotEmpty) {
          _log('APNS token ready (len=${apns.length})');
          return true;
        }
        _log('APNS not ready ($i/$_maxApnsRetries)');
      } catch (e) {
        _log('getAPNSToken error ($i/$_maxApnsRetries): $e');
      }
      await Future.delayed(_retryDelay);
    }
    return false;
  }

  static Future<void> _sendTokenToBackend(String token) async {
    final safe = token.trim();
    if (safe.isEmpty) {
      _log('backend send skipped: empty token');
      return;
    }
    if (_lastSentToken == safe) {
      _log('backend send skipped: same token already sent');
      return;
    }
    try {
      final dio = getIt<Dio>();
      _log('sending token → ${Constants.coreDevices}');
      await dio.post(
        Constants.coreDevices,
        data: <String, dynamic>{'token': safe},
      );
      _lastSentToken = safe;
      _log('token sent successfully');
    } catch (e) {
      _log('token send failed: $e');
    }
  }

  static void _listenMessages() {
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        _log('initial message: ${message.data}');
        _syncOrderAlertSoundAfterPushOpen(message, source: 'initial');
        _handleMessage(message, source: 'initial');
      }
    });

    FirebaseMessaging.onMessage.listen((message) {
      _log('foreground message received');
      _handleMessage(message, source: 'foreground');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _log('message opened app');
      _syncOrderAlertSoundAfterPushOpen(message, source: 'openedApp');
      _handleMessage(message, source: 'openedApp');
    });
  }

  static void _syncOrderAlertSoundAfterPushOpen(
    RemoteMessage message, {
    required String source,
  }) {
    final ws = getIt<VendorNotificationsWsService>();
    _log('[$source] push-open payload: ${message.data}');
    if (_looksLikeNewOrderMessage(message)) {
      _log('[$source] new order detected from push → start sound loop');
      unawaited(ws.startNewOrderAlertSoundLoop(forceRestart: true));
    }
    // Payload format turlicha bo'lishi mumkin; backend holati bilan aniq sync qilamiz.
    unawaited(ws.syncAlertSoundWithPendingOrdersFromBackend(forceRestart: true));
    // Ba'zi holatlarda app resume bo'lgach network/state kechroq tiklanadi.
    unawaited(
      Future<void>.delayed(
        const Duration(milliseconds: 900),
        () => ws.syncAlertSoundWithPendingOrdersFromBackend(forceRestart: true),
      ),
    );
    unawaited(
      Future<void>.delayed(
        const Duration(seconds: 2),
        () => ws.syncAlertSoundWithPendingOrdersFromBackend(forceRestart: true),
      ),
    );
    unawaited(
      Future<void>.delayed(
        const Duration(seconds: 5),
        () => ws.syncAlertSoundWithPendingOrdersFromBackend(forceRestart: true),
      ),
    );
  }

  static bool _looksLikeNewOrderMessage(RemoteMessage message) {
    final data = message.data;
    final type = (data['type'] ?? '').toString().trim().toLowerCase();
    if (type == 'order_created') return true;
    const keys = <String>[
      'order_id',
      'orderId',
      'id',
      'order_number',
      'orderNumber',
    ];
    for (final key in keys) {
      final value = data[key];
      if (value != null && value.toString().trim().isNotEmpty) return true;
    }
    return false;
  }

  static void _handleMessage(RemoteMessage message, {required String source}) {
    _log('[$source] data=${message.data} | title=${message.notification?.title}');
  }
}