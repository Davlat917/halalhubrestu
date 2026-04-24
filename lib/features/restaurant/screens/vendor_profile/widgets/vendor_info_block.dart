import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/extensions/size_extension.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_me/vendor_me_model.dart';
import 'package:halalhub_restaurant/features/restaurant/utils/vendor_profile_formatting.dart';

class VendorInfoBlock extends StatelessWidget {
  const VendorInfoBlock({
    super.key,
    required this.vendor,
    required this.workLine,
    required this.maxWidth,
    this.infoTopPadding,
  });

  final VendorMeModel vendor;
  final String? workLine;
  final double maxWidth;

  /// `null` → mobil uchun standart bo‘shliq; `0` → tablet qatorida logo yonida.
  final double? infoTopPadding;

  @override
  Widget build(BuildContext context) {
    final padTop = infoTopPadding ?? context.wOf(52, maxWidth);
    final detailsTextStyle = AppTextStyle.regular14(
      context,
      color: StaticColors.c4C4C4C,
      aW: maxWidth,
    );
    return Padding(
      padding: EdgeInsets.only(top: padTop),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            vendor.name ?? '—',
            style: AppTextStyle.semibold20(
              context,
              aW: maxWidth,
              color: StaticColors.black,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            vendor.description ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: detailsTextStyle,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 24,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    TranslationKeys.vendorProfileRating.tr(context: context),
                    style: AppTextStyle.semibold14(
                      context,
                      color: StaticColors.black,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.star_border_rounded,
                    color: StaticColors.yellow,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(ratingLabel(vendor), style: detailsTextStyle),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    TranslationKeys.vendorProfileWorkHour.tr(context: context),
                    style: AppTextStyle.semibold14(
                      context,
                      color: StaticColors.black,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(workLine ?? '—', style: detailsTextStyle),
                ],
              ),
            ],
          ),
          if ((vendor.currentStatus ?? '').isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              TranslationKeys.vendorProfileStatus.tr(
                context: context,
                namedArgs: {'status': vendor.currentStatus ?? ''},
              ),
              style: AppTextStyle.medium12(
                context,
                color: StaticColors.primary,
              ),
            ), //
          ],
        ],
      ),
    );
  }
}
