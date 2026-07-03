import 'package:dio/dio.dart';
import 'package:halalhub_restaurant/core/constants/constants.dart';
import 'package:halalhub_restaurant/core/network/network_exception.dart'
    show ExceptionHandler, NetworkException, UnexpectedException;
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/delete_account/data/delete_account_repository.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: DeleteAccountRepository)
class DeleteAccountRepositoryImpl implements DeleteAccountRepository {
  DeleteAccountRepositoryImpl(this._dio);

  final Dio _dio;

  static const _mobileHeaders = {'X-Client-Type': 'mobile'};

  Never _rethrow(Object e) {
    final ex = ExceptionHandler.handleException(e);
    if (ex is NetworkException) throw ex;
    if (ex is UnexpectedException) {
      throw NetworkException(message: ex.message);
    }
    throw NetworkException(message: ex.toString());
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final response = await _dio.delete(
        Constants.deleteAccount,
        options: Options(headers: _mobileHeaders),
      );
      final code = response.statusCode ?? 0;
      if (code == 200 || code == 201 || code == 202 || code == 204) {
        return;
      }
      throw NetworkException(
        message: 'Account delete failed (${response.statusCode ?? ''})',
      );
    } catch (e) {
      _rethrow(e);
    }
  }
}
