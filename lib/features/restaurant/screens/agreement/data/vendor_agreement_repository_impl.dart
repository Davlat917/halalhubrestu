import 'package:halalhub_restaurant/core/network/network_exception.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/agreement/data/vendor_agreement_api.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/agreement/data/vendor_agreement_repository.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/agreement/models/vendor_agreement_model.dart';

class VendorAgreementRepositoryImpl extends VendorAgreementRepository {
  VendorAgreementRepositoryImpl(this._api);

  final VendorAgreementApi _api;

  @override
  Future<VendorAgreementModel> getAgreement({required int vendorId}) async {
    try {
      final body = await _api.getAgreement(vendorId: vendorId);
      if (body.isEmpty) {
        throw NetworkException(message: 'Invalid vendor agreement response');
      }
      return VendorAgreementModel.fromJson(body);
    } catch (e) {
      final ex = ExceptionHandler.handleException(e);
      if (ex is NetworkException) throw ex;
      throw NetworkException(message: ex.toString());
    }
  }

  @override
  Future<VendorAgreementModel> acceptStep({required int vendorId, required int stepNumber}) async {
    try {
      final body = await _api.acceptStep(vendorId: vendorId, stepNumber: stepNumber);
      if (body.isEmpty) {
        throw NetworkException(message: 'Invalid accept agreement response');
      }
      return VendorAgreementModel.fromJson(body);
    } catch (e) {
      final ex = ExceptionHandler.handleException(e);
      if (ex is NetworkException) throw ex;
      throw NetworkException(message: ex.toString());
    }
  }

  @override
  Future<VendorAgreementModel> signAgreement({required int vendorId, required String initials}) async {
    try {
      final body = await _api.signAgreement(vendorId: vendorId, initials: initials);
      if (body.isEmpty) {
        throw NetworkException(message: 'Invalid agreement sign response');
      }
      return VendorAgreementModel.fromJson(body);
    } catch (e) {
      final ex = ExceptionHandler.handleException(e);
      if (ex is NetworkException) throw ex;
      throw NetworkException(message: ex.toString());
    }
  }

  @override
  Future<VendorAgreementDownloadModel> downloadAgreement({
    required int vendorId,
  }) async {
    try {
      final response = await _api.downloadAgreement(vendorId: vendorId);
      final bytes = response.data ?? const <int>[];
      if (bytes.isEmpty) {
        throw NetworkException(message: 'Agreement file is empty');
      }
      final disposition = response.headers.value('content-disposition') ?? '';
      final fileName = _extractFileName(disposition) ?? 'vendor_agreement_$vendorId.pdf';
      return VendorAgreementDownloadModel(bytes: bytes, fileName: fileName);
    } catch (e) {
      final ex = ExceptionHandler.handleException(e);
      if (ex is NetworkException) throw ex;
      throw NetworkException(message: ex.toString());
    }
  }

  String? _extractFileName(String contentDisposition) {
    if (contentDisposition.isEmpty) return null;
    final parts = contentDisposition.split(';');
    for (final raw in parts) {
      final part = raw.trim();
      if (part.toLowerCase().startsWith('filename=')) {
        return part.substring(9).replaceAll('"', '').trim();
      }
    }
    return null;
  }
}
