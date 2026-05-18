import 'package:dio/dio.dart';
import 'package:halalhub_restaurant/core/constants/constants.dart';
import 'package:halalhub_restaurant/core/network/network_exception.dart'
    show ExceptionHandler, NetworkException, UnexpectedException;
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/data/models/vendor_finance_period.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/data/models/vendor_finance_transactions_page_model.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/data/repositories/finance_repository.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: FinanceRepository)
class FinanceRepositoryImpl implements FinanceRepository {
  FinanceRepositoryImpl(this._dio);

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
  Future<VendorFinanceTransactionsPageModel> fetchTransactions({
    required VendorFinancePeriod period,
    String? nextPageUrl,
  }) async {
    try {
      final Response<dynamic> response;
      final next = nextPageUrl?.trim();
      if (next != null && next.isNotEmpty) {
        final uri = Uri.tryParse(next);
        response = uri != null && uri.hasScheme
            ? await _dio.getUri(uri)
            : await _dio.get(next);
      } else {
        response = await _dio.get<dynamic>(
          Constants.vendorsFinanceTransactions,
          queryParameters: {'period': period.apiValue},
        );
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw NetworkException(
          message: 'Invalid finance transactions response',
        );
      }
      return VendorFinanceTransactionsPageModel.fromJson(
        Map<String, dynamic>.from(data),
      );
    } catch (e) {
      _rethrow(e);
    }
  }
}
