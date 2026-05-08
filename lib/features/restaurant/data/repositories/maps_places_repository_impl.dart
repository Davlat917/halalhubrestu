import 'package:dio/dio.dart';
import 'package:halalhub_restaurant/core/constants/constants.dart';
import 'package:halalhub_restaurant/core/network/network_exception.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/places/address_model.dart';
import 'package:halalhub_restaurant/features/restaurant/data/repositories/maps_places_repo.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: MapsPlacesRepo)
class MapsPlacesRepositoryImpl implements MapsPlacesRepo {
  MapsPlacesRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<AddressModel> getAddress({
    required String uuid,
    required String query,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        Constants.addressApi,
        queryParameters: <String, dynamic>{
          'input': query,
          'key': Constants.mapKey,
          'sessiontoken': uuid,
        },
      );
      final data = response.data;
      if (data == null) {
        throw UnexpectedException(message: 'Empty places response');
      }
      return AddressModel.fromJson(data);
    } catch (e) {
      throw ExceptionHandler.handleException(e);
    }
  }

  @override
  Future<({double lat, double lng})> getPlaceLocation({
    required String placeId,
    required String sessionToken,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        Constants.placeDetailsApi,
        queryParameters: <String, dynamic>{
          'place_id': placeId,
          'fields': 'geometry/location',
          'key': Constants.mapKey,
          'sessiontoken': sessionToken,
        },
      );
      final data = response.data;
      if (data == null) {
        throw UnexpectedException(message: 'Empty place details response');
      }
      final status = data['status'] as String?;
      if (status != 'OK') {
        throw UnexpectedException(
          message: status ?? 'Place details failed',
        );
      }
      final result = data['result'];
      if (result is! Map<String, dynamic>) {
        throw UnexpectedException(message: 'Invalid place details result');
      }
      final geometry = result['geometry'];
      if (geometry is! Map<String, dynamic>) {
        throw UnexpectedException(message: 'Missing geometry');
      }
      final location = geometry['location'];
      if (location is! Map<String, dynamic>) {
        throw UnexpectedException(message: 'Missing location');
      }
      final lat = location['lat'];
      final lng = location['lng'];
      if (lat is! num || lng is! num) {
        throw UnexpectedException(message: 'Invalid coordinates');
      }
      return (lat: lat.toDouble(), lng: lng.toDouble());
    } catch (e) {
      throw ExceptionHandler.handleException(e);
    }
  }
}
