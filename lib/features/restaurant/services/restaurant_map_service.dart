import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class RestaurantMapService {
  static const LatLng defaultCenter = LatLng(40.73061, -73.935242);

  CameraPosition initialCamera() =>
      const CameraPosition(target: defaultCenter, zoom: 12);

  Set<Marker> markersFor(LatLng? selected) {
    if (selected == null) return const <Marker>{};
    return {
      Marker(
        markerId: const MarkerId('restaurant_location'),
        position: selected,
      ),
    };
  }
}
