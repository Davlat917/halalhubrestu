import 'package:halalhub_restaurant/core/network/network_exception.dart'
    show ExceptionHandler, NetworkException, UnexpectedException;
import 'package:halalhub_restaurant/features/restaurant/screens/receipt_printer/data/models/clover_connect_response.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/receipt_printer/data/models/vendor_pos_providers_response.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/receipt_printer/data/vendor_pos_providers_api.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/receipt_printer/data/vendor_pos_providers_repository.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: VendorPosProvidersRepository)
class VendorPosProvidersRepositoryImpl implements VendorPosProvidersRepository {
  VendorPosProvidersRepositoryImpl(this._api);

  final VendorPosProvidersApi _api;

  Never _rethrow(Object e) {
    final ex = ExceptionHandler.handleException(e);
    if (ex is NetworkException) throw ex;
    if (ex is UnexpectedException) {
      throw NetworkException(message: ex.message);
    }
    throw NetworkException(message: ex.toString());
  }

  @override
  Future<VendorPosProvidersResponse> fetchProviders() async {
    try {
      final map = await _api.fetchProviders();
      return VendorPosProvidersResponse.fromJson(map);
    } catch (e) {
      _rethrow(e);
    }
  }

  @override
  Future<VendorPosProvidersResponse> selectProvider({
    required int vendorId,
    required String provider,
  }) async {
    try {
      final map = await _api.selectProvider(
        vendorId: vendorId,
        provider: provider,
      );
      return VendorPosProvidersResponse.fromJson(map);
    } catch (e) {
      _rethrow(e);
    }
  }

  @override
  Future<CloverConnectResponse> connectClover({required int vendorId}) async {
    try {
      final map = await _api.connectClover(vendorId: vendorId);
      return CloverConnectResponse.fromJson(map);
    } catch (e) {
      _rethrow(e);
    }
  }
}
