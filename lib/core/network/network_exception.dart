import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';

// ── Hech narsa o'zgarmadi ──────────────────────────────────────
class NetworkException implements Exception {
  final String message;
  final int? statusCode;

  NetworkException({required this.message, this.statusCode});

  @override
  String toString() => "NetworkException: $message (Status Code: $statusCode)";
}

class ServerException extends NetworkException {
  ServerException({required super.message, super.statusCode});
}

class CacheException implements Exception {
  final String message;
  CacheException({required this.message});

  @override
  String toString() => "CacheException: $message";
}

class UnexpectedException implements Exception {
  final String message;
  UnexpectedException({String? message})
    : message = message ?? TranslationKeys.networkUnexpectedError.tr();

  @override
  String toString() => "UnexpectedException: $message";
}

// ── Faqat shu o'zgardi ────────────────────────────────────────
class ExceptionHandler {
  static Exception handleException(dynamic error) {
    if (error is DioException) return _handleDio(error);
    if (error is NetworkException) return error;
    if (error is ServerException) return error;
    if (error is CacheException) return error;
    return UnexpectedException();
  }

  static Exception _handleDio(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return NetworkException(
          message: TranslationKeys.networkConnectionTimeout.tr(),
          statusCode: -1,
        );

      case DioExceptionType.receiveTimeout:
        return NetworkException(
          message: TranslationKeys.networkReceiveTimeout.tr(),
          statusCode: -2,
        );

      case DioExceptionType.sendTimeout:
        return NetworkException(
          message: TranslationKeys.networkSendTimeout.tr(),
          statusCode: -3,
        );

      case DioExceptionType.connectionError:
        return NetworkException(
          message: TranslationKeys.networkNoInternet.tr(),
          statusCode: -4,
        );

      case DioExceptionType.cancel:
        return NetworkException(
          message: TranslationKeys.networkRequestCancelled.tr(),
          statusCode: -5,
        );

      case DioExceptionType.badResponse:
        return _handleHttpError(error.response);

      default:
        return NetworkException(
          message: TranslationKeys.networkUnknownError.tr(),
          statusCode: -99,
        );
    }
  }

  static Exception _handleHttpError(Response? response) {
    if (response == null) return UnexpectedException();

    final statusCode = response.statusCode ?? 0;
    final message = _extractMessage(response.data);

    return ServerException(message: message, statusCode: statusCode);
  }

  /// JSON, plain text yoki HTML — barchasidan xabarni oladi
  static String _extractMessage(dynamic data) {
    if (data == null) return TranslationKeys.networkServerError.tr();

    if (data is Map<String, dynamic>) {
      const keys = ['error', 'message', 'detail', 'msg', 'description'];
      for (final key in keys) {
        final value = data[key];
        if (value is String && value.isNotEmpty) return value;
      }

      // { "errors": { "field": ["msg"] } }
      final errors = data['errors'];
      if (errors is Map<String, dynamic>) {
        final first = errors.values.firstOrNull;
        if (first is List && first.isNotEmpty) return first.first.toString();
        if (first is String) return first;
      }

      // { "non_field_errors": ["msg"] }
      final nonField = data['non_field_errors'];
      if (nonField is List && nonField.isNotEmpty) {
        return nonField.first.toString();
      }

      // DRF field validation: { "ein_number": ["Invalid format"] }
      // yoki { "field": "error text" } ko'rinishlarini ham ushlaymiz.
      for (final entry in data.entries) {
        final value = entry.value;
        if (value is String && value.trim().isNotEmpty) {
          return value.trim();
        }
        if (value is List && value.isNotEmpty) {
          final first = value.first;
          final text = first?.toString().trim() ?? '';
          if (text.isNotEmpty) return text;
        }
      }
    }

    if (data is String) return _sanitize(data);

    return TranslationKeys.networkServerError.tr();
  }

  /// HTML tag yoki uzun text kelsa tozalaydi
  static String _sanitize(String raw) {
    if (raw.isEmpty) return TranslationKeys.networkServerError.tr();
    if (raw.contains('<')) {
      final stripped = raw
          .replaceAll(RegExp(r'<[^>]*>'), ' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
      return stripped.isEmpty
          ? TranslationKeys.networkServerError.tr()
          : stripped;
    }
    return raw.length > 200 ? '${raw.substring(0, 200)}…' : raw;
  }
}
