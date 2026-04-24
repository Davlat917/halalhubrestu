part of 'vendor_profile_bloc.dart';

sealed class VendorProfileState extends Equatable {
  const VendorProfileState();

  @override
  List<Object?> get props => [];
}

final class VendorProfileInitial extends VendorProfileState {}

final class VendorProfileLoading extends VendorProfileState {}

final class VendorProfileLoaded extends VendorProfileState {
  const VendorProfileLoaded(this.vendor);

  final VendorMeModel vendor;

  @override
  List<Object?> get props => [vendor];
}

final class VendorProfileFailure extends VendorProfileState {
  const VendorProfileFailure(this.exception);

  final NetworkException exception;

  @override
  List<Object?> get props => [exception];
}
