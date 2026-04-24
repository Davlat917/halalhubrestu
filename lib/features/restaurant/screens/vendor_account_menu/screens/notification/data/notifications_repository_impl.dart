import 'package:dio/dio.dart';
import 'package:halalhub_restaurant/core/constants/constants.dart';
import 'package:halalhub_restaurant/core/network/network_exception.dart'
    show ExceptionHandler, NetworkException, UnexpectedException;
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/notification/data/models/notifications_page_result.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/notification/data/notifications_repository.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: NotificationsRepository)
class NotificationsRepositoryImpl implements NotificationsRepository {
  NotificationsRepositoryImpl(this._dio);

  final Dio _dio;

  Never _rethrow(Object e) {
    final ex = ExceptionHandler.handleException(e);
    if (ex is NetworkException) throw ex;
    if (ex is UnexpectedException) {
      throw NetworkException(message: ex.message);
    }
    throw NetworkException(message: ex.toString());
  }

  @override
  Future<NotificationsPageResult> fetchNotifications({String? nextPageUrl}) async {
    try {
      final Response<dynamic> response;
      final next = nextPageUrl?.trim();
      if (next != null && next.isNotEmpty) {
        final uri = Uri.tryParse(next);
        if (uri != null && uri.hasScheme) {
          response = await _dio.getUri(uri);
        } else {
          response = await _dio.get(next);
        }
      } else {
        response = await _dio.get(Constants.coreNotifications);
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw NetworkException(message: 'Invalid notifications response');
      }
      return NotificationsPageResult.fromJson(data);
    } catch (e) {
      _rethrow(e);
    }
  }
}
