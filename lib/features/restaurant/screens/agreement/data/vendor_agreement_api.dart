import 'package:dio/dio.dart';
import 'package:halalhub_restaurant/core/constants/constants.dart';

class VendorAgreementApi {
  VendorAgreementApi(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> getAgreement({required int vendorId}) async {
    final response = await _dio.get<Map<String, dynamic>>(Constants.vendorAgreement(vendorId));
    return Map<String, dynamic>.from(response.data ?? const <String, dynamic>{});
  }

  Future<Map<String, dynamic>> acceptStep({required int vendorId, required int stepNumber}) async {
    final response = await _dio.post<Map<String, dynamic>>(Constants.vendorAgreementAcceptStep(vendorId), data: {'step_number': stepNumber});
    return Map<String, dynamic>.from(response.data ?? const <String, dynamic>{});
  }

  Future<Map<String, dynamic>> signAgreement({required int vendorId, required String initials}) async {
    final response = await _dio.post<Map<String, dynamic>>(Constants.vendorAgreementSign(vendorId), data: {'initials': initials});
    return Map<String, dynamic>.from(response.data ?? const <String, dynamic>{});
  }

  Future<Response<List<int>>> downloadAgreement({required int vendorId}) {
    return _dio.get<List<int>>(
      Constants.vendorAgreementDownload(vendorId),
      options: Options(responseType: ResponseType.bytes),
    );
  }
}
