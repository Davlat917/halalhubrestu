import 'package:dio/dio.dart';
import 'package:halalhub_restaurant/core/constants/constants.dart';
import 'package:halalhub_restaurant/core/network/network_exception.dart'
    show ExceptionHandler, NetworkException, UnexpectedException;
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/data/models/vendor_finance_period.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/data/models/vendor_finance_transactions_page_model.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/data/models/vendor_finance_transactions_pdf_file.dart';
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

  @override
  Future<VendorFinanceTransactionsPdfFile> downloadTransactionsPdf({
    required VendorFinancePeriod period,
  }) async {
    try {
      final response = await _dio.get<List<int>>(
        Constants.vendorsFinanceTransactionsPdf,
        queryParameters: {'period': period.apiValue},
        options: Options(responseType: ResponseType.bytes),
      );
      final bytes = response.data ?? const <int>[];
      if (bytes.isEmpty) {
        throw NetworkException(message: 'Finance transactions PDF is empty');
      }
      final disposition = response.headers.value('content-disposition') ?? '';
      final fileName = _extractFileName(disposition) ??
          'finance_transactions_${period.apiValue}.pdf';
      return VendorFinanceTransactionsPdfFile(bytes: bytes, fileName: fileName);
    } catch (e) {
      _rethrow(e);
    }
  }

  String? _extractFileName(String contentDisposition) {
    if (contentDisposition.isEmpty) return null;
    final parts = contentDisposition.split(';');
    for (final raw in parts) {
      final part = raw.trim();
      if (!part.toLowerCase().startsWith('filename=')) continue;
      var name = part.substring('filename='.length).trim();
      if (name.startsWith('"') && name.endsWith('"') && name.length >= 2) {
        name = name.substring(1, name.length - 1);
      }
      if (name.isNotEmpty) return name;
    }
    return null;
  }
}
