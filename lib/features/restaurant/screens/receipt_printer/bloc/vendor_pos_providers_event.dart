import 'package:equatable/equatable.dart';

abstract class VendorPosProvidersEvent extends Equatable {
  const VendorPosProvidersEvent();

  @override
  List<Object?> get props => [];
}

class VendorPosProvidersRequested extends VendorPosProvidersEvent {
  const VendorPosProvidersRequested();
}

class VendorPosProviderSelected extends VendorPosProvidersEvent {
  const VendorPosProviderSelected({
    required this.vendorId,
    required this.provider,
  });

  final int vendorId;
  final String provider;

  @override
  List<Object?> get props => [vendorId, provider];
}
