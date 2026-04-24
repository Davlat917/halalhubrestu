import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:halalhub_restaurant/core/constants/constants.dart';
import 'package:halalhub_restaurant/core/network/auth_interceptor/auth_interceptor.dart';

@module
abstract class NetworkModule {
  @lazySingleton
  Dio dio(AuthInterceptor authInterceptor, Logger logger) {
    final dio = Dio();

    dio.options.baseUrl = "${Constants.baseUrl}${Constants.version}";

    dio.interceptors.add(authInterceptor);

    if (kDebugMode) {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            options.extra['startTime'] = DateTime.now(); // 🕒 boshlanish vaqtini saqlaymiz
            logger.i("📤 REQUEST ➡️  ${options.method} ${options.uri}");
            logger.d("🧾 Headers:\n${options.headers}");
            if (options.data != null) {
              try {
                final prettyBody = const JsonEncoder.withIndent('  ').convert(options.data);
                logger.d("📦 Body:\n$prettyBody");
              } catch (_) {
                logger.d("📦 Body:\n${options.data}");
              }
            }
            return handler.next(options);
          },
          onResponse: (response, handler) {
            final startTime = response.requestOptions.extra['startTime'] as DateTime?;
            final duration = startTime != null ? DateTime.now().difference(startTime) : null;
            logger.i("📥 RESPONSE ✅ ${response.statusCode} ${response.requestOptions.uri}");
            if (duration != null) {
              logger.i("⏱️ Response time: ${duration.inMilliseconds} ms");
            }
            try {
              final prettyJson = const JsonEncoder.withIndent('  ').convert(response.data);
              logger.d("📄 Response Body:\n$prettyJson");
            } catch (_) {
              logger.d("📄 Response Body:\n${response.data}");
            }
            return handler.next(response);
          },
          onError: (DioError e, handler) {
            final startTime = e.requestOptions.extra['startTime'] as DateTime?;
            final duration = startTime != null ? DateTime.now().difference(startTime) : null;

            logger.e(
              "❌ ERROR 🚨 ${e.response?.statusCode} ${e.requestOptions.uri}",
              error: e,
              stackTrace: e.stackTrace,
            );

            if (duration != null) {
              logger.i("⏱️ Error response time: ${duration.inMilliseconds} ms");
            }

            if (e.response?.data != null) {
              try {
                final prettyError = const JsonEncoder.withIndent('  ').convert(e.response!.data);
                logger.e("💥 Error Response:\n$prettyError");
              } catch (_) {
                logger.e("💥 Error Response:\n${e.response!.data}");
              }
            }

            return handler.next(e);
          },
        ),
      );
    }
    return dio;
  }
}
