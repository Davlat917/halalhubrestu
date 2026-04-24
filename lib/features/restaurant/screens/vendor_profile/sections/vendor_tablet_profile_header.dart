import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/extensions/size_extension.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/router/app_router.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/core/widgets/custom_button.dart';
import 'package:halalhub_restaurant/core/widgets/network_image_chache.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:halalhub_restaurant/features/restaurant/bloc/vendor_profile/vendor_profile_bloc.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_me/vendor_me_model.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_profile/widgets/vendor_info_block.dart';
import 'package:halalhub_restaurant/features/restaurant/utils/vendor_profile_formatting.dart';

/// Tablet: banner (past), brand logo chap pastki burchakda, nom/tavsif/reyting/o‘ngda tahrirlash.
class VendorTabletProfileHeader extends StatelessWidget {
  const VendorTabletProfileHeader({super.key, required this.vendor, required this.workLine, required this.layoutWidth});

  final VendorMeModel vendor;
  final String? workLine;
  final double layoutWidth;

  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.orientationOf(context) == Orientation.portrait;
    final pad = context.wOf(20, layoutWidth);
    final bannerH = context.wOf(142, layoutWidth).clamp(118.0, 158.0);
    final logoSize = context.wOf(86, layoutWidth).clamp(72.0, 96.0);
    final logoUrl = effectiveImageUrl(vendor.logoUrl, vendor.logo);
    final coverUrl = effectiveImageUrl(vendor.coverUrl, vendor.coverImage);
    final gapAfterLogo = context.wOf(16, layoutWidth);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: bannerH + logoSize * 0.4,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: 10,
                left: 16,
                right: 16,
                height: bannerH,
                child: NetworkImageCache(
                  imgUrl: coverUrl,
                  heightH: bannerH,
                  widthW: double.infinity,
                  radius: 10,
                  fit: BoxFit.cover, //
                ),
              ),
              Positioned(
                left: pad,
                top: bannerH - logoSize * 0.46,
                child: Row(
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => context.router.push(const VendorAccountMenuRoute()),
                        borderRadius: BorderRadius.circular(11),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: StaticColors.white, width: 3),
                            boxShadow: [BoxShadow(color: StaticColors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4))],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(11),
                            child: NetworkImageCache(imgUrl: logoUrl, widthW: logoSize, heightH: logoSize, radius: 0, fit: BoxFit.cover),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(pad, 0, pad, 0),
          child: (isPortrait || layoutWidth < 540)
              ? Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      VendorInfoBlock(vendor: vendor, workLine: workLine, maxWidth: layoutWidth, infoTopPadding: 0),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          label: TranslationKeys.editProfile.tr(context: context),
                          height: context.wOf(34, layoutWidth),
                          textStyle: AppTextStyle.medium12(context, color: StaticColors.white, aW: layoutWidth),
                          width: double.infinity,
                          onPressed: () => context.router.push(const UpdateRestaurantRoute()).then((updated) {
                            if (updated == true && context.mounted) {
                              context.read<VendorProfileBloc>().add(const VendorProfileRequested());
                            }
                          }),
                          backgroundColor: StaticColors.primary,
                          foregroundColor: StaticColors.white, //
                        ),
                      ),
                    ],
                  ),
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: logoSize + gapAfterLogo),
                    Expanded(
                      child: VendorInfoBlock(vendor: vendor, workLine: workLine, maxWidth: layoutWidth, infoTopPadding: 0),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 12, top: 2),
                      child: CustomButton(
                        padding: EdgeInsets.zero,
                        height: context.wOf(16, layoutWidth),
                        textStyle: AppTextStyle.medium10(context, color: StaticColors.white, aW: layoutWidth),
                        label: TranslationKeys.editProfile.tr(context: context),
                        width: context.wOf(100, layoutWidth),
                        onPressed: () => context.router.push(const UpdateRestaurantRoute()).then((updated) {
                          if (updated == true && context.mounted) {
                            context.read<VendorProfileBloc>().add(const VendorProfileRequested());
                          }
                        }),
                        backgroundColor: StaticColors.primary,
                        foregroundColor: StaticColors.white, //
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
