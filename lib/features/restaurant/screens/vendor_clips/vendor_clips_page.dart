import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/core/widgets/shimmer_item.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_clips/bloc/vendor_clips_bloc.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_clips/bloc/vendor_clips_event.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_clips/bloc/vendor_clips_state.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_clips/mixins/vendor_clips_page_mixin.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_clips/sections/vendor_clips_loaded_section.dart';
import 'package:shimmer/shimmer.dart';

/// Vendor kabineti → Clips: alohida sahifa vidjeti (bloc [VendorProfileScaffold] da beriladi).
class VendorClipsPage extends StatefulWidget {
  const VendorClipsPage({super.key});

  @override
  State<VendorClipsPage> createState() => _VendorClipsPageState();
}

class _VendorClipsPageState extends State<VendorClipsPage>
    with VendorClipsPageMixin {
  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: StaticColors.white,
      child: BlocConsumer<VendorClipsBloc, VendorClipsState>(
        listener: onVendorClipsListen,
        builder: (context, state) {
          if (state is VendorClipsInitial || state is VendorClipsLoading) {
            return const _VendorClipsLoadingSkeleton();
          }
          if (state is VendorClipsFailure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.exception.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: StaticColors.c9AA0A6),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => context.read<VendorClipsBloc>().add(
                        const VendorClipsRequested(),
                      ),
                      child: Text(
                        TranslationKeys.clipsRetry.tr(context: context),
                      ), //
                    ),
                  ],
                ),
              ),
            );
          }
          if (state is VendorClipsLoaded) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: VendorClipsLoadedSection(
                clips: state.clips,
                nextPageUrl: state.nextPageUrl,
                isLoadingMore: state.isLoadingMore,
                onRefresh: () => pullRefresh(context),
                onLoadMore: () => context.read<VendorClipsBloc>().add(
                  const VendorClipsLoadMoreRequested(),
                ),
                onUploadTap: () => openUploadDialog(context),
                onPlayClip: (c) => openShortsViewer(context, state.clips, c),
                onEditClip: (clip) => openEditDialog(context, clip),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _VendorClipsLoadingSkeleton extends StatelessWidget {
  const _VendorClipsLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: StaticColors.cE2E2E2,
      highlightColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final crossAxisCount = width >= 1200
                ? 4
                : width >= 900
                ? 3
                : 2;
            const spacing = 10.0;
            final itemWidth = (width - (crossAxisCount - 1) * spacing) / crossAxisCount;
            final itemHeight = itemWidth / (4 / 5);
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const ShimmerBox(height: 30, width: 150, radius: 8),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: crossAxisCount * 2,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: spacing,
                      mainAxisSpacing: spacing,
                      childAspectRatio: 4 / 5,
                    ),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _uploadCardSkeleton();
                      }
                      return _clipCardSkeleton(itemHeight);
                    },
                  ),
                  const SizedBox(height: 16),
                  const Center(
                    child: ShimmerBox(height: 22, width: 120, radius: 8),
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _uploadCardSkeleton() {
    return const DecoratedBox(
      decoration: BoxDecoration(
        color: Color(0x0F12A84E),
        borderRadius: BorderRadius.all(Radius.circular(12)),
        border: Border.fromBorderSide(BorderSide(color: StaticColors.primary)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ShimmerBox(height: 46, width: 46, radius: 23),
          SizedBox(height: 10),
          ShimmerBox(height: 14, width: 90, radius: 7),
          SizedBox(height: 6),
          ShimmerBox(height: 12, width: 70, radius: 6),
        ],
      ),
    );
  }

  Widget _clipCardSkeleton(double itemHeight) {
    final mediaHeight = itemHeight * 0.82;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          Positioned.fill(
            child: ShimmerBox(height: itemHeight, radius: 12),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: ShimmerBox(height: mediaHeight, radius: 12),
          ),
          const Positioned(
            top: 8,
            right: 8,
            child: ShimmerBox(height: 28, width: 28, radius: 14),
          ),
          Positioned(
            top: mediaHeight / 2 - 26,
            left: 0,
            right: 0,
            child: const Center(
              child: ShimmerBox(height: 52, width: 52, radius: 26),
            ),
          ),
          Positioned(
            left: 10,
            right: 10,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ShimmerBox(height: 10, width: 120, radius: 5),
                SizedBox(height: 6),
                ShimmerBox(height: 10, width: 90, radius: 5),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
