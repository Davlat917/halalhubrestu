import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_media_clip/vendor_media_clip_model.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_clips/widgets/vendor_clip_card.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_clips/widgets/vendor_clips_upload_card.dart';

class VendorClipsLoadedSection extends StatelessWidget {
  const VendorClipsLoadedSection({
    super.key,
    required this.clips,
    required this.nextPageUrl,
    required this.isLoadingMore,
    required this.onRefresh,
    required this.onLoadMore,
    required this.onUploadTap,
    required this.onPlayClip,
    required this.onEditClip,
  });

  final List<VendorMediaClipModel> clips;
  final String? nextPageUrl;
  final bool isLoadingMore;
  final Future<void> Function() onRefresh;
  final VoidCallback onLoadMore;
  final VoidCallback onUploadTap;
  final void Function(VendorMediaClipModel clip) onPlayClip;
  final void Function(VendorMediaClipModel clip) onEditClip;

  int _crossAxisCount(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final shortest = MediaQuery.sizeOf(context).shortestSide;
    final land = MediaQuery.orientationOf(context) == Orientation.landscape;
    if (shortest >= 600) {
      return land ? 4 : 3;
    }
    if (w >= 500) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    final cross = _crossAxisCount(context);
    final titleStyle = AppTextStyle.semibold24(
      context,
      color: StaticColors.black,
    );

    return RefreshIndicator(
      color: StaticColors.primary,
      onRefresh: onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Text(
                TranslationKeys.clipsTitle.tr(context: context),
                style: titleStyle,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 16),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cross,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                if (index == 0) {
                  return VendorClipsUploadCard(onTap: onUploadTap);
                }
                final clip = clips[index - 1];
                return VendorClipCard(
                  clip: clip,
                  onPlay: () => onPlayClip(clip),
                  onEdit: () => onEditClip(clip),
                );
              }, childCount: 1 + clips.length),
            ),
          ),
          if (nextPageUrl case final String n when n.trim().isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Center(
                  child: TextButton(
                    onPressed: isLoadingMore ? null : onLoadMore,
                    child: isLoadingMore
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: StaticColors.primary,
                            ),
                          )
                        : Text(
                            TranslationKeys.clipsLoadMore.tr(context: context),
                            style: AppTextStyle.medium16(
                              context,
                              color: StaticColors.primary,
                            ),
                          ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
