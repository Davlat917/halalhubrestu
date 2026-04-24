import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:halalhub_restaurant/core/constants/constants.dart';
import 'package:halalhub_restaurant/core/di/injection.dart';
import 'package:halalhub_restaurant/core/router/app_router.dart';
import 'package:halalhub_restaurant/core/storage/storage.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

@lazySingleton
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor(this._storage, this._logger);

  final Storage _storage;
  final Logger _logger;
  final Dio _tokenDio = Dio(BaseOptions(baseUrl: Constants.baseUrl));

  static final _json = const JsonEncoder.withIndent('  ');
  bool _redirectingToAuth = false;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _storage.token.call();
    if (kDebugMode) {
      final hasToken = token != null && token.isNotEmpty;
      _logger.d(
        '┌── AuthInterceptor (request)\n'
        '│  ${options.method} ${options.uri}\n'
        '└  Authorization: ${hasToken ? "Bearer <storage> → qo‘shiladi" : "(yo‘q)"}',
      );
    }

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
      options.headers['Accept-Language'] = 'en';
    }

    if (kDebugMode) {
      _logVendorProductPatchRequest(options);
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      _logVendorProductPatchResponse(response);
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (kDebugMode) {
      _logVendorProductPatchError(err);
    }

    if (kDebugMode && err.response?.statusCode == 401) {
      _logAuthError(err);
    }

    final response = err.response;
    final requestOptions = err.requestOptions;
    final statusCode = response?.statusCode ?? 0;

    if (statusCode >= 500 && response != null) {
      // 5xx xatolar markaziy tarzda bir xil ko'rinishga keltiriladi.
      response.data = const {'message': 'Server error'};
    }

    if (response?.statusCode == 401 &&
        (response?.data['code'] == 'token_not_valid' ||
            response?.data['detail'] == 'Given token not valid for any token type')) {
      final refreshToken = _storage.refreshToken.call();

      if (refreshToken == null || refreshToken.isEmpty) {
        if (kDebugMode) {
          _logger.w('║  AuthInterceptor  ·  refresh skipped (no refresh_token in storage)');
        }
        await _expireSessionAndGoToLogin();
        return handler.next(err);
      }

      const refreshPath = '${Constants.version}${Constants.refreshToken}';
      final refreshUri = Uri.parse('${Constants.baseUrl}$refreshPath');

      if (kDebugMode) {
        final rtPreview = refreshToken.length <= 8
            ? '***'
            : '${refreshToken.substring(0, 8)}…';
        _logger.i(
          '╔══════════════════════════════════════════════════════════════════════════════\n'
          '║  AuthInterceptor  ·  token refresh (POSTMAN-style)\n'
          '╠══════════════════════════════════════════════════════════════════════════════\n'
          '║  POST $refreshUri\n'
          '╠──────── Body (masked) ───────────────────────────────────────────────────────\n'
          '${_json.convert({'refresh_token': rtPreview})}\n'
          '╚══════════════════════════════════════════════════════════════════════════════',
        );
      }

      try {
        final refreshResponse = await _tokenDio.post<Map<String, dynamic>>(
          refreshPath,
          data: {'refresh_token': refreshToken},
          options: Options(
            headers: {'Content-Type': 'application/json'},
          ),
        );

        final newAccessToken = refreshResponse.data?['access_token'] as String?;

        if (kDebugMode) {
          final status = refreshResponse.statusCode;
          final bodyPreview = refreshResponse.data;
          final buf = StringBuffer()
            ..writeln('╔══════════════════════════════════════════════════════════════════════════════')
            ..writeln('║  AuthInterceptor  ·  token refresh OK')
            ..writeln('╠══════════════════════════════════════════════════════════════════════════════')
            ..writeln('║  HTTP $status  POST $refreshUri')
            ..writeln('╠──────── Response ───────────────────────────────────────────────────────────');
          try {
            final safe = Map<String, dynamic>.from(refreshResponse.data ?? {});
            if (safe['access_token'] is String) {
              final t = safe['access_token'] as String;
              safe['access_token'] =
                  t.length <= 12 ? '***' : '${t.substring(0, 12)}…';
            }
            buf.writeln(_json.convert(safe));
          } catch (_) {
            buf.writeln('  $bodyPreview');
          }
          buf.writeln('╚══════════════════════════════════════════════════════════════════════════════');
          _logger.i(buf.toString());
        }

        if (newAccessToken == null || newAccessToken.isEmpty) {
          await _expireSessionAndGoToLogin();
          return handler.next(err);
        }

        await _storage.token.set(newAccessToken);

        final newOptions = Options(
          method: requestOptions.method,
          headers: {
            ...requestOptions.headers,
            'Authorization': 'Bearer $newAccessToken',
          },
        );

        final dio = Dio(BaseOptions(baseUrl: requestOptions.baseUrl));
        final cloneResponse = await dio.request<dynamic>(
          requestOptions.path,
          data: requestOptions.data,
          queryParameters: requestOptions.queryParameters,
          options: newOptions,
        );

        return handler.resolve(cloneResponse);
      } catch (e, st) {
        if (kDebugMode) {
          _logger.e(
            '╔══════════════════════════════════════════════════════════════════════════════\n'
            '║  AuthInterceptor  ·  token refresh FAILED\n'
            '╠══════════════════════════════════════════════════════════════════════════════\n'
            '║  $e\n'
            '╚══════════════════════════════════════════════════════════════════════════════',
            error: e,
            stackTrace: st,
          );
        }
        await _expireSessionAndGoToLogin();
        return handler.next(err);
      }
    }

    return handler.next(err);
  }

  Future<void> _expireSessionAndGoToLogin() async {
    await _storage.token.delete();
    await _storage.refreshToken.delete();
    if (_redirectingToAuth) return;
    _redirectingToAuth = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        getIt<AppRouter>().replaceAll([
          const AuthFlowRoute(children: [SignInRoute()]),
        ]);
      } finally {
        _redirectingToAuth = false;
      }
    });
  }

  void _logAuthError(DioException err) {
    final req = err.requestOptions;
    final res = err.response;
    final buf = StringBuffer()
      ..writeln('╔══════════════════════════════════════════════════════════════════════════════')
      ..writeln('║  AuthInterceptor  ·  error (before handling)')
      ..writeln('╠══════════════════════════════════════════════════════════════════════════════')
      ..writeln('║  ${req.method} ${req.uri}')
      ..writeln('║  ${err.type}  ·  status: ${res?.statusCode}')
      ..writeln('╠──────── Response data ────────────────────────────────────────────────────────');
    if (res?.data != null) {
      try {
        buf.writeln(_json.convert(res!.data));
      } catch (_) {
        buf.writeln('  ${res?.data}');
      }
    } else {
      buf.writeln('  (no body)');
    }
    buf.writeln('╚══════════════════════════════════════════════════════════════════════════════');
    _logger.e(buf.toString());
  }

  bool _isVendorProductPatch(RequestOptions options) {
    final method = options.method.toUpperCase();
    if (method != 'PATCH') return false;
    final path = options.path;
    return path.contains('/vendors/vendors/') && path.contains('/products/');
  }

  void _logVendorProductPatchRequest(RequestOptions options) {
    if (!_isVendorProductPatch(options)) return;
    final data = options.data;
    final buf = StringBuffer()
      ..writeln('╔══════════════════════════════════════════════════════════════════════════════')
      ..writeln('║  Vendor Product PATCH · request')
      ..writeln('╠══════════════════════════════════════════════════════════════════════════════')
      ..writeln('║  ${options.method} ${options.uri}')
      ..writeln('╠──────── Payload ─────────────────────────────────────────────────────────────');

    if (data is FormData) {
      final fields = <String, dynamic>{for (final e in data.fields) e.key: e.value};
      final files = data.files.map((e) => '${e.key}:${e.value.filename}').toList();
      buf.writeln(_json.convert({'fields': fields, 'files': files}));
    } else if (data != null) {
      try {
        buf.writeln(_json.convert(data));
      } catch (_) {
        buf.writeln('  $data');
      }
    } else {
      buf.writeln('  (empty body)');
    }

    buf.writeln('╚══════════════════════════════════════════════════════════════════════════════');
    _logger.i(buf.toString());
  }

  void _logVendorProductPatchResponse(Response response) {
    final options = response.requestOptions;
    if (!_isVendorProductPatch(options)) return;
    final buf = StringBuffer()
      ..writeln('╔══════════════════════════════════════════════════════════════════════════════')
      ..writeln('║  Vendor Product PATCH · response')
      ..writeln('╠══════════════════════════════════════════════════════════════════════════════')
      ..writeln('║  ${options.method} ${options.uri}')
      ..writeln('║  status: ${response.statusCode}')
      ..writeln('╠──────── Response body ───────────────────────────────────────────────────────');
    try {
      buf.writeln(_json.convert(response.data));
    } catch (_) {
      buf.writeln('  ${response.data}');
    }
    buf.writeln('╚══════════════════════════════════════════════════════════════════════════════');
    _logger.i(buf.toString());
  }

  void _logVendorProductPatchError(DioException err) {
    final options = err.requestOptions;
    if (!_isVendorProductPatch(options)) return;
    final buf = StringBuffer()
      ..writeln('╔══════════════════════════════════════════════════════════════════════════════')
      ..writeln('║  Vendor Product PATCH · error')
      ..writeln('╠══════════════════════════════════════════════════════════════════════════════')
      ..writeln('║  ${options.method} ${options.uri}')
      ..writeln('║  type: ${err.type}  ·  status: ${err.response?.statusCode}')
      ..writeln('╠──────── Error body ─────────────────────────────────────────────────────────');
    if (err.response?.data != null) {
      try {
        buf.writeln(_json.convert(err.response!.data));
      } catch (_) {
        buf.writeln('  ${err.response?.data}');
      }
    } else {
      buf.writeln('  (no body)');
    }
    buf.writeln('╚══════════════════════════════════════════════════════════════════════════════');
    _logger.e(buf.toString());
  }
}
