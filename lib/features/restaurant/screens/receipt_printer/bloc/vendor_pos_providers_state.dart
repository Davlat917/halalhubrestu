import 'package:equatable/equatable.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/receipt_printer/data/models/vendor_pos_providers_response.dart';

enum VendorPosProvidersLoadStatus { initial, loading, success, failure }

class VendorPosProvidersState extends Equatable {
  const VendorPosProvidersState({
    this.status = VendorPosProvidersLoadStatus.initial,
    this.data,
    this.errorMessage,
    this.isSubmitting = false,
  });

  final VendorPosProvidersLoadStatus status;
  final VendorPosProvidersResponse? data;
  final String? errorMessage;
  final bool isSubmitting;

  VendorPosProvidersState copyWith({
    VendorPosProvidersLoadStatus? status,
    VendorPosProvidersResponse? data,
    String? errorMessage,
    bool clearError = false,
    bool? isSubmitting,
  }) {
    return VendorPosProvidersState(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [status, data, errorMessage, isSubmitting];
}
