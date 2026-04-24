import 'package:equatable/equatable.dart';
import 'package:halalhub_restaurant/core/di/base_bloc.dart';
import 'package:halalhub_restaurant/core/network/network_exception.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_me/vendor_me_model.dart';
import 'package:halalhub_restaurant/features/restaurant/data/repositories/restaurant_repo.dart';
import 'package:injectable/injectable.dart';

part 'vendor_profile_event.dart';
part 'vendor_profile_state.dart';

@injectable
class VendorProfileBloc
    extends BaseBloc<VendorProfileEvent, VendorProfileState> {
  VendorProfileBloc(this._repo) : super(VendorProfileInitial()) {
    onAsync<VendorProfileRequested>(_onRequested);
  }

  final RestaurantRepo _repo;

  Future<void> _onRequested(VendorProfileRequested event) async {
    await callable<VendorMeModel>(
      future: _repo.getVendorMe(),
      buildOnStart: () => VendorProfileLoading(),
      buildOnData: (data) => VendorProfileLoaded(data),
      buildOnError: (error) => VendorProfileFailure(error),
    );
  }
}
