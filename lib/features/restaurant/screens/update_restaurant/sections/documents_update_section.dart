import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:halalhub_restaurant/core/extensions/size_extension.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/create_restaurant/widgets/upload_pick_tile.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/update_restaurant/bloc/update_restaurant_cubit.dart';

class DocumentsUpdateSection extends StatelessWidget {
  const DocumentsUpdateSection({super.key, this.uploadTileHeight = 110});

  final double uploadTileHeight;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return BlocBuilder<UpdateRestaurantCubit, UpdateRestaurantState>(
      buildWhen: (p, c) =>
          p.hasCertificate != c.hasCertificate ||
          p.certificateFiles != c.certificateFiles ||
          p.existingCertificates != c.existingCertificates,
      builder: (context, state) {
        final cubit = context.read<UpdateRestaurantCubit>();
        String fileNameFromUrl(String? url) {
          if (url == null || url.isEmpty) {
            return TranslationKeys.commonCertificate.tr(context: context);
          }
          final normalized = url.split('?').first;
          final name = normalized.split('/').last;
          return name.isEmpty
              ? TranslationKeys.commonCertificate.tr(context: context)
              : name;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              TranslationKeys.createRestaurantHasCertificateQuestion.tr(
                context: context,
              ),
              style: AppTextStyle.semibold20(
                context,
                color: StaticColors.black,
              ),
            ),
            SizedBox(height: context.wOf(8, w)),
            _CertificateOptionTile(
              title: TranslationKeys.createRestaurantNoCertificate.tr(
                context: context,
              ),
              selected: !state.hasCertificate,
              onTap: () => cubit.setHasCertificate(false),
            ),
            _CertificateOptionTile(
              title: TranslationKeys.createRestaurantYesCertificate.tr(
                context: context,
              ),
              selected: state.hasCertificate,
              onTap: () => cubit.setHasCertificate(true),
            ),
            UploadPickTile(
              availableWidth: w,
              title: TranslationKeys.createRestaurantUploadCertificate.tr(
                context: context,
              ),
              subtitle: TranslationKeys.createRestaurantCertificateTypes.tr(
                context: context,
              ),
              buttonLabel: TranslationKeys.browseFile.tr(context: context),
              onPressed: cubit.pickCertificates,
              height: uploadTileHeight,
              buttonHeight: 40,
              useDashedBorder: true,
              emptyIconAssetPath: 'assets/images/add_image_icon.png', //
              compactInLandscape: false,
            ),
            SizedBox(height: context.wOf(10, w)),
            Text(
              TranslationKeys.createRestaurantUploaded.tr(context: context),
              style: AppTextStyle.medium14(context, color: StaticColors.black),
            ),
            SizedBox(height: context.wOf(6, w)),
            ...state.existingCertificates.map(
              (item) => Container(
                height: 50,
                margin: EdgeInsets.only(bottom: context.wOf(8, w)),
                padding: EdgeInsets.symmetric(horizontal: context.wOf(12, w)),
                decoration: BoxDecoration(
                  color: StaticColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: StaticColors.primary),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        fileNameFromUrl(item.file),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.regular14(context),
                      ),
                    ),
                    IconButton(
                      onPressed: item.id == null
                          ? null
                          : () => cubit.removeExistingCertificate(item.id!),
                      constraints: const BoxConstraints.tightFor(
                        width: 32,
                        height: 32,
                      ),
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ...state.certificateFiles.asMap().entries.map(
              (entry) => Container(
                height: 50,
                margin: EdgeInsets.only(bottom: context.wOf(8, w)),
                padding: EdgeInsets.symmetric(horizontal: context.wOf(12, w)),
                decoration: BoxDecoration(
                  color: StaticColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: StaticColors.primary),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.value.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.regular14(context),
                      ),
                    ),
                    IconButton(
                      onPressed: () => cubit.removeCertificateAt(entry.key),
                      constraints: const BoxConstraints.tightFor(
                        width: 32,
                        height: 32,
                      ),
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CertificateOptionTile extends StatelessWidget {
  const _CertificateOptionTile({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? StaticColors.primary : StaticColors.c9AA0A6,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(title)),
          ],
        ),
      ),
    );
  }
}
