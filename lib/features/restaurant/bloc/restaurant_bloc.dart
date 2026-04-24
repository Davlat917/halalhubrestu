import 'package:equatable/equatable.dart';
import 'package:halalhub_restaurant/core/di/base_bloc.dart';
import 'package:halalhub_restaurant/core/network/network_exception.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_create/vendor_create_model.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_me/vendor_me_model.dart';
import 'package:halalhub_restaurant/features/restaurant/data/repositories/restaurant_repo.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';

part 'restaurant_event.dart';
part 'restaurant_state.dart';

@injectable
class RestaurantBloc extends BaseBloc<RestaurantEvent, RestaurantState> {
  RestaurantBloc(this._repo) : super(RestaurantInitial()) {
    onAsync<VendorCreateSubmitted>(_onVendorCreateSubmitted);
    onAsync<VendorUpdateSubmitted>(_onVendorUpdateSubmitted);
  }

  final RestaurantRepo _repo;

  Future<void> _onVendorCreateSubmitted(VendorCreateSubmitted event) async {
    await callable<VendorCreateModel>(
      future: _repo.vendorCreate(
        payload: event.payload,
        profileImage: event.profileImage,
        bannerImage: event.bannerImage,
        certificateFiles: event.certificateFiles,
      ),
      buildOnStart: () => RestaurantLoading(),
      buildOnData: (data) => RestaurantCreateSuccess(data),
      buildOnError: (error) {
        if (error.statusCode == 404) {
          return RestaurantPendingApproval(message: error.message);
        }
        return RestaurantFailure(error);
      },
    );
  }

  Future<void> _onVendorUpdateSubmitted(VendorUpdateSubmitted event) async {
    await callable<VendorMeModel>(
      future: _repo.vendorUpdate(
        payload: event.payload,
        profileImage: event.profileImage,
        bannerImage: event.bannerImage,
        certificateFiles: event.certificateFiles,
      ),
      buildOnStart: () => RestaurantLoading(),
      buildOnData: (data) => RestaurantUpdateSuccess(data),
      buildOnError: (error) => RestaurantFailure(error),
    );
  }
}
