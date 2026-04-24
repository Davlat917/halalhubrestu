import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/extensions/size_extension.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/core/widgets/network_image_chache.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_me/vendor_me_model.dart';

class VendorAboutSection extends StatelessWidget {
  const VendorAboutSection({
    super.key,
    required this.vendor,
    required this.maxWidth,
  });

  final VendorMeModel vendor;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final isWide = maxWidth >= 860;
    final spacing = context.wOf(16, maxWidth);
    return isWide
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _restaurantInfoCard(context)),
              SizedBox(width: spacing),
              Expanded(child: _certificatesCard(context)),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _restaurantInfoCard(context),
              SizedBox(height: spacing),
              _certificatesCard(context),
            ],
          );
  }

  Widget _restaurantInfoCard(BuildContext context) {
    final isMobile = maxWidth < 600;
    final phone = [vendor.phoneNumber1, vendor.phoneNumber2]
        .whereType<String>()
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .join(',  ');

    Widget line(String title, String value) => isMobile
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$title:',
                style: AppTextStyle.medium16(
                  context,
                  color: StaticColors.black,
                  aW: maxWidth,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppTextStyle.regular14(
                  context,
                  color: StaticColors.c4C4C4C,
                ),
              ),
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: context.wOf(120, maxWidth).clamp(92.0, 128.0),
                child: Text(
                  '$title:',
                  style: AppTextStyle.medium14(
                    context,
                    color: StaticColors.black,
                    aW: maxWidth,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  style: AppTextStyle.regular14(
                    context,
                    color: StaticColors.c4C4C4C,
                  ),
                ),
              ),
            ],
          );

    final items = <({String title, String value})>[
      if ((vendor.address ?? '').trim().isNotEmpty)
        (
          title: TranslationKeys.updateAddressLabel.tr(context: context),
          value: vendor.address!.trim(),
        ),
      if (phone.isNotEmpty)
        (
          title: TranslationKeys.updatePhoneNumberLabel.tr(context: context),
          value: phone,
        ),
      if ((vendor.email ?? '').trim().isNotEmpty)
        (
          title: TranslationKeys.authEmail.tr(context: context),
          value: vendor.email!.trim(),
        ),
    ];

    return Container(
      padding: EdgeInsets.all(context.wOf(16, maxWidth)),
      decoration: BoxDecoration(
        color: StaticColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: StaticColors.cE2E2E2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            TranslationKeys.vendorProfileRestaurantInfo.tr(context: context),
            style: AppTextStyle.semibold20(
              context,
              size: isMobile ? 22 : null,
              aW: maxWidth,
              color: StaticColors.black,
            ),
          ),
          SizedBox(height: isMobile ? 18 : 16),
          for (int i = 0; i < items.length; i++) ...[
            line(items[i].title, items[i].value),
            if (i != items.length - 1) ...[
              SizedBox(height: isMobile ? 14 : 12),
              const Divider(color: StaticColors.cE2E2E2, height: 1),
              SizedBox(height: isMobile ? 14 : 12),
            ] else
              const SizedBox(height: 4),
          ],
        ],
      ),
    );
  }

  Widget _certificatesCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.wOf(16, maxWidth)),
      decoration: BoxDecoration(
        color: StaticColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: StaticColors.cE2E2E2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            TranslationKeys.vendorProfileCertificates.tr(context: context),
            style: AppTextStyle.semibold20(
              context,
              aW: maxWidth,
              color: StaticColors.black,
            ),
          ),
          const SizedBox(height: 12),
          if (vendor.certificates.isEmpty)
            Text(
              TranslationKeys.vendorProfileNoCertificates.tr(context: context),
              style: AppTextStyle.regular14(
                context,
                color: StaticColors.c9AA0A6,
              ),
            )
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: vendor.certificates
                  .map(
                    (c) => ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: NetworkImageCache(
                        imgUrl: c.file,
                        widthW: context.wOf(120, maxWidth).clamp(94.0, 140.0),
                        heightH: context.wOf(168, maxWidth).clamp(120.0, 180.0),
                        radius: 0,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}
