import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:halalhub_restaurant/core/network/network_exception.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/receipt_printer/bloc/vendor_pos_providers_event.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/receipt_printer/bloc/vendor_pos_providers_state.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/receipt_printer/data/models/vendor_pos_providers_response.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/receipt_printer/data/vendor_pos_providers_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class VendorPosProvidersBloc extends Bloc<VendorPosProvidersEvent, VendorPosProvidersState> {
  VendorPosProvidersBloc(this._repo) : super(const VendorPosProvidersState()) {
    on<VendorPosProvidersRequested>(_onRequested);
    on<VendorPosProviderSelected>(_onProviderSelected);
  }

  final VendorPosProvidersRepository _repo;

  Future<void> _onRequested(
    VendorPosProvidersRequested event,
    Emitter<VendorPosProvidersState> emit,
  ) async {
    emit(state.copyWith(status: VendorPosProvidersLoadStatus.loading, clearError: true));
    try {
      final data = await _repo.fetchProviders();
      emit(
        state.copyWith(
          status: VendorPosProvidersLoadStatus.success,
          data: data,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: VendorPosProvidersLoadStatus.failure,
          errorMessage: e is NetworkException ? e.message : e.toString(),
        ),
      );
    }
  }

  Future<void> _onProviderSelected(
    VendorPosProviderSelected event,
    Emitter<VendorPosProvidersState> emit,
  ) async {
    if (state.isSubmitting) return;
    emit(state.copyWith(isSubmitting: true, clearError: true));
    try {
      final selected = await _repo.selectProvider(
        vendorId: event.vendorId,
        provider: event.provider,
      );
      final mergedData = _mergeSelectedResponse(
        current: state.data,
        incoming: selected,
        selectedProvider: event.provider,
      );
      emit(
        state.copyWith(
          status: VendorPosProvidersLoadStatus.success,
          data: mergedData,
          clearError: true,
          isSubmitting: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: VendorPosProvidersLoadStatus.failure,
          errorMessage: e is NetworkException ? e.message : e.toString(),
          isSubmitting: false,
        ),
      );
    }
  }

  VendorPosProvidersResponse _mergeSelectedResponse({
    required VendorPosProvidersResponse? current,
    required VendorPosProvidersResponse incoming,
    required String selectedProvider,
  }) {
    final normalized = selectedProvider.trim().toLowerCase();
    if (incoming.providers.isNotEmpty) return incoming;
    final prev = current;
    if (prev == null) return incoming;

    final providers = prev.providers
        .map(
          (item) => item.copyWith(
            active: item.providerId == normalized,
          ),
        )
        .toList();
    return prev.copyWith(
      vendorId: incoming.vendorId == 0 ? prev.vendorId : incoming.vendorId,
      vendorName: incoming.vendorName.isEmpty ? prev.vendorName : incoming.vendorName,
      activeProvider: incoming.activeProvider.isEmpty ? normalized : incoming.activeProvider,
      providers: providers,
    );
  }
}
