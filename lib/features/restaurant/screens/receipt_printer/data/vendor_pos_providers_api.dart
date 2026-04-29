import 'package:dio/dio.dart';
import 'package:halalhub_restaurant/core/constants/constants.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class VendorPosProvidersApi {
  VendorPosProvidersApi(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> fetchProviders() async {
    final response = await _dio.get<Map<String, dynamic>>(Constants.deliveryVendorPosProviders);
    return Map<String, dynamic>.from(response.data ?? const <String, dynamic>{});
  }

  Future<Map<String, dynamic>> selectProvider({
    required int vendorId,
    required String provider,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      Constants.deliveryVendorPosSelect,
      data: {
        'vendor_id': vendorId,
        'provider': provider,
      },
    );
    return Map<String, dynamic>.from(response.data ?? const <String, dynamic>{});
  }

  /// Body yo‘q, lekin X-Vendor-Id headeri shart.
  Future<Map<String, dynamic>> connectClover({required int vendorId}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      Constants.deliveryCloverConnect,
      options: Options(
        headers: <String, int>{
          'X-Vendor-Id': vendorId,
        },
      ),
    );
    return Map<String, dynamic>.from(response.data ?? const <String, dynamic>{});
  }
}
