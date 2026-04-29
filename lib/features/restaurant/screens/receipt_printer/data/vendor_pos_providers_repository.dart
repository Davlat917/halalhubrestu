import 'package:halalhub_restaurant/features/restaurant/screens/receipt_printer/data/models/clover_connect_response.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/receipt_printer/data/models/vendor_pos_providers_response.dart';

abstract class VendorPosProvidersRepository {
  Future<VendorPosProvidersResponse> fetchProviders();

  Future<VendorPosProvidersResponse> selectProvider({
    required int vendorId,
    required String provider,
  });

  Future<CloverConnectResponse> connectClover({required int vendorId});
}
