import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Placeholder when the WebView has no `access` value in localStorage.
const String kAccessTokenNotFoundPlaceholder = 'Token not found';

class DeviceRegistrationService {
  static const String _deviceRegisterUrl = 'https://backend-api.wehalalhub.com/api/v1/core/devices/';

  static String? _accessToken;
  static String? _lastSyncedFcmToken;

  static Future<void> setAccessToken(String? accessToken) async {
    final normalizedToken = accessToken?.trim();
    if (normalizedToken == null ||
        normalizedToken.isEmpty ||
        normalizedToken == kAccessTokenNotFoundPlaceholder) {
      return;
    }
    if (_accessToken == normalizedToken) {
      if (kDebugMode) {
        debugPrint('⏭️ [TOKEN] Unchanged → skip sync');
      }
      return;
    }

    _accessToken = normalizedToken;
    if (kDebugMode) {
      debugPrint('✅ [TOKEN] New access token stored');
    }
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
        body: jsonEncode(
          <String, String>{'token': token},
        ),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        _lastSyncedFcmToken = token;
        if (kDebugMode) {
          debugPrint('FCM token sent to backend');
        }
        return;
      }

      if (kDebugMode) {
        debugPrint(
          'FCM token not sent: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('FCM token sync error: $e');
      }
    }
  }
}
