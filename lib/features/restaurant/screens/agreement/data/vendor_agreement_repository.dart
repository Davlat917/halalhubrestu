import 'package:halalhub_restaurant/features/restaurant/screens/agreement/models/vendor_agreement_model.dart';

class VendorAgreementDownloadModel {
  const VendorAgreementDownloadModel({
    required this.bytes,
    required this.fileName,
  });

  final List<int> bytes;
  final String fileName;
}

abstract class VendorAgreementRepository {
  Future<VendorAgreementModel> getAgreement({required int vendorId});

  Future<VendorAgreementModel> acceptStep({required int vendorId, required int stepNumber});

  Future<VendorAgreementModel> signAgreement({required int vendorId, required String initials});

  Future<VendorAgreementDownloadModel> downloadAgreement({required int vendorId});
}
