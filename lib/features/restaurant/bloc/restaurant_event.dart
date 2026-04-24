part of 'restaurant_bloc.dart';

sealed class RestaurantEvent extends Equatable {
  const RestaurantEvent();

  @override
  List<Object?> get props => [];
}

final class VendorCreateSubmitted extends RestaurantEvent {
  const VendorCreateSubmitted({
    required this.payload,
    this.profileImage,
    this.bannerImage,
    this.certificateFiles = const [],
  });

  final VendorCreateModel payload;
  final XFile? profileImage;
  final XFile? bannerImage;
  final List<XFile> certificateFiles;

  @override
  List<Object?> get props => [
    payload,
    profileImage,
    bannerImage,
    certificateFiles,
  ];
}

final class VendorUpdateSubmitted extends RestaurantEvent {
  const VendorUpdateSubmitted({
    required this.payload,
    this.profileImage,
    this.bannerImage,
    this.certificateFiles = const [],
  });

  final VendorCreateModel payload;
  final XFile? profileImage;
  final XFile? bannerImage;
  final List<XFile> certificateFiles;

  @override
  List<Object?> get props => [
    payload,
    profileImage,
    bannerImage,
    certificateFiles,
  ];
}
