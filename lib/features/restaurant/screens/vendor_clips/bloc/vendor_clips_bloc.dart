import 'package:flutter/foundation.dart';
import 'package:halalhub_restaurant/core/di/base_bloc.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_media_clip/vendor_media_clip_model.dart';
import 'package:halalhub_restaurant/features/restaurant/data/repositories/restaurant_repo.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_clips/bloc/vendor_clips_event.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_clips/bloc/vendor_clips_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class VendorClipsBloc extends BaseBloc<VendorClipsEvent, VendorClipsState> {
  VendorClipsBloc(this._repo) : super(const VendorClipsInitial()) {
    onAsync<VendorClipsRequested>(_onRequested);
    onAsync<VendorClipsRefreshRequested>(_onRefresh);
    onAsync<VendorClipsLoadMoreRequested>(_onLoadMore);
  }

  final RestaurantRepo _repo;

  Future<void> _onRequested(VendorClipsRequested event) async {
    await callable<VendorMediaPageResult>(
      future: _repo.getVendorMedia(),
      buildOnStart: () => const VendorClipsLoading(),
      buildOnData: (data) => VendorClipsLoaded(
        clips: data.results,
        nextPageUrl: data.next,
      ),
      buildOnError: (e) => VendorClipsFailure(e),
    );
  }

  Future<void> _onRefresh(VendorClipsRefreshRequested event) async {
    await callable<VendorMediaPageResult>(
      future: _repo.getVendorMedia(),
      buildOnStart: () => const VendorClipsLoading(),
      buildOnData: (data) => VendorClipsLoaded(
        clips: data.results,
        nextPageUrl: data.next,
      ),
      buildOnError: (e) => VendorClipsFailure(e),
    );
  }

  Future<void> _onLoadMore(VendorClipsLoadMoreRequested event) async {
    final emit = currentEmitter;
    if (emit == null) return;
    final current = state;
    if (current is! VendorClipsLoaded) return;
    final next = current.nextPageUrl;
    if (next == null || next.isEmpty || current.isLoadingMore) return;

    emit(current.copyWith(isLoadingMore: true));

    try {
      final page = await _repo.getVendorMedia(url: next);
      emit(
        VendorClipsLoaded(
          clips: [...current.clips, ...page.results],
          nextPageUrl: page.next,
          isLoadingMore: false,
        ),
      );
    } catch (e, st) {
      if (kDebugMode) debugPrint('VendorClips load more: $e\n$st');
      emit(current.copyWith(isLoadingMore: false));
    }
  }
}
