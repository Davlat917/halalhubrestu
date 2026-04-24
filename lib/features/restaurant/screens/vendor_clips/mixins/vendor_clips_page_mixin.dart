import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/di/injection.dart';
import 'package:halalhub_restaurant/core/widgets/display/display.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_media_clip/vendor_media_clip_model.dart';
import 'package:halalhub_restaurant/features/restaurant/data/repositories/restaurant_repo.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_clips/bloc/vendor_clips_bloc.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_clips/bloc/vendor_clips_event.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_clips/bloc/vendor_clips_state.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_clips/widgets/vendor_clips_edit_dialog.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_clips/widgets/vendor_clips_shorts_viewer.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_clips/widgets/vendor_clips_upload_dialog.dart';

mixin VendorClipsPageMixin<T extends StatefulWidget> on State<T> {
  /// Xatolik sahifada ko‘rinadi; shu yerda faqat keyingi (masalan, muvaffaqiyat) toast’lari qo‘shiladi.
  void onVendorClipsListen(BuildContext context, VendorClipsState state) {}

  Future<void> pullRefresh(BuildContext context) async {
    context.read<VendorClipsBloc>().add(const VendorClipsRefreshRequested());
    await context.read<VendorClipsBloc>().stream.firstWhere(
      (s) => s is VendorClipsLoaded || s is VendorClipsFailure,
    );
  }

  void openShortsViewer(
    BuildContext context,
    List<VendorMediaClipModel> clips,
    VendorMediaClipModel tapped,
  ) {
    if (clips.isEmpty) return;
    final i = clips.indexWhere((e) => e.id == tapped.id);
    final start = i < 0 ? 0 : i;
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) =>
            VendorClipsShortsViewer(clips: clips, initialIndex: start),
      ),
    );
  }

  Future<void> openUploadDialog(BuildContext context) async {
    final uploaded = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => VendorClipsUploadDialog(repo: getIt<RestaurantRepo>()),
    );
    if (!mounted) return;
    if (uploaded == true) {
      this.context.read<VendorClipsBloc>().add(
        const VendorClipsRefreshRequested(),
      );
      getIt<Display>().info(TranslationKeys.clipsUploadedSuccess.tr());
    }
  }

  Future<void> openEditDialog(
    BuildContext context,
    VendorMediaClipModel clip,
  ) async {
    final updated = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          VendorClipsEditDialog(repo: getIt<RestaurantRepo>(), clip: clip),
    );
    if (!mounted) return;
    if (updated == true) {
      this.context.read<VendorClipsBloc>().add(
        const VendorClipsRefreshRequested(),
      );
      getIt<Display>().info(TranslationKeys.clipsDescriptionUpdated.tr());
    }
  }
}
