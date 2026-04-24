import 'package:dio/dio.dart';
import 'package:halalhub_restaurant/core/network/api_response/api_exception.dart';
import 'package:halalhub_restaurant/core/network/api_response/api_status_message.dart';

class ApiResponseHandler {
  /// [response] – Dio Response yoki http.Response
  /// [fromJson] – success bo‘lsa data parse qiladigan funksiya
  static T handle<T>(
    Response response,
    T Function(dynamic data) fromJson,
  ) {
    final statusCode = response.statusCode ?? 0;

    if (statusCode >= 200 && statusCode < 300) {
      return fromJson(response.data);
    } else {
      final message = ApiStatusMessages.getMessage(statusCode);
      throw ApiException(statusCode, message);
    }
  }
}
