import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class DeviceRegistrationService {
  static const String _deviceRegisterUrl = 'https://infonexuz.uz/api/v1/core/devices/';

  static String? _accessToken;
  static String? _lastSyncedFcmToken;

  static Future<void> setAccessToken(String? accessToken) async {
    final normalizedToken = accessToken?.trim();
    if (normalizedToken == null || normalizedToken.isEmpty || normalizedToken == 'Token topilmadi') {
      return;
    }

    _accessToken = normalizedToken;
  }

  static Future<void> syncDeviceToken(String? fcmToken) async {
    final token = fcmToken?.trim() ?? '';
    final accessToken = _accessToken?.trim();

    if (token.isEmpty || accessToken == null || accessToken.isEmpty) {
      return;
    }

    if (_lastSyncedFcmToken == token) {
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(_deviceRegisterUrl),
        headers: <String, String>{
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(<String, String>{'token': token}),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        _lastSyncedFcmToken = token;
        debugPrint('FCM token backendga yuborildi');
        return;
      }

      debugPrint('FCM token yuborilmadi: ${response.statusCode} ${response.body}');
    } catch (e) {
      debugPrint('FCM token yuborishda xato: $e');
    }
  }
}
