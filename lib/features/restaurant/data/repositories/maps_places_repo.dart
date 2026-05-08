import 'package:halalhub_restaurant/features/restaurant/data/models/places/address_model.dart';

abstract class MapsPlacesRepo {
  Future<AddressModel> getAddress({
    required String uuid,
    required String query,
  });

  /// Autocomplete sessiyasini yakunlash uchun — [uuid] bilan bir xil `sessiontoken`.
  Future<({double lat, double lng})> getPlaceLocation({
    required String placeId,
    required String sessionToken,
  });
}
