part of 'restaurant_bloc.dart';

sealed class RestaurantState extends Equatable {
  const RestaurantState();

  @override
  List<Object?> get props => [];
}

final class RestaurantInitial extends RestaurantState {}

final class RestaurantLoading extends RestaurantState {}

final class RestaurantCreateSuccess extends RestaurantState {
  const RestaurantCreateSuccess(this.data);
  final VendorCreateModel data;

  @override
  List<Object?> get props => [data];
}

final class RestaurantUpdateSuccess extends RestaurantState {
  const RestaurantUpdateSuccess(this.data);
  final VendorMeModel data;

  @override
  List<Object?> get props => [data];
}

final class RestaurantFailure extends RestaurantState {
  const RestaurantFailure(this.exception);
  final NetworkException exception;

  @override
  List<Object?> get props => [exception];
}

final class RestaurantPendingApproval extends RestaurantState {
  const RestaurantPendingApproval({this.message});
  final String? message;

  @override
  List<Object?> get props => [message];
}
