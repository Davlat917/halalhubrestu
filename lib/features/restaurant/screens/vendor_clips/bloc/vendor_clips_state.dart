import 'package:equatable/equatable.dart';
import 'package:halalhub_restaurant/core/network/network_exception.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_media_clip/vendor_media_clip_model.dart';

sealed class VendorClipsState extends Equatable {
  const VendorClipsState();

  @override
  List<Object?> get props => [];
}

final class VendorClipsInitial extends VendorClipsState {
  const VendorClipsInitial();
}

final class VendorClipsLoading extends VendorClipsState {
  const VendorClipsLoading();
}

final class VendorClipsLoaded extends VendorClipsState {
  const VendorClipsLoaded({
    required this.clips,
    this.nextPageUrl,
    this.isLoadingMore = false,
  });

  final List<VendorMediaClipModel> clips;
  final String? nextPageUrl;
  final bool isLoadingMore;

  VendorClipsLoaded copyWith({
    List<VendorMediaClipModel>? clips,
    String? nextPageUrl,
    bool? isLoadingMore,
  }) {
    return VendorClipsLoaded(
      clips: clips ?? this.clips,
      nextPageUrl: nextPageUrl ?? this.nextPageUrl,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [clips, nextPageUrl, isLoadingMore];
}

final class VendorClipsFailure extends VendorClipsState {
  const VendorClipsFailure(this.exception);

  final NetworkException exception;

  @override
  List<Object?> get props => [exception];
}
