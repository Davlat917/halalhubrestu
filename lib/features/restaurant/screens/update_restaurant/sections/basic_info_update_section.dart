import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/extensions/size_extension.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/core/widgets/common_textfield.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_category/vendor_category_model.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/create_restaurant/widgets/upload_pick_tile.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/update_restaurant/bloc/update_restaurant_cubit.dart';

class BasicInfoUpdateSection extends StatelessWidget {
  const BasicInfoUpdateSection({
    super.key,
    required this.validateName,
    required this.validateEmail,
    required this.validateRequired,
    required this.validateOptionalUsPhone,
    this.showCategory = true, //
    this.showMediaRow = true,
  });

  final String? Function(String?) validateName;
  final String? Function(String?) validateEmail;
  final String? Function(String?, {required String field}) validateRequired;
  final String? Function(String?, {required String? otherValue})
  validateOptionalUsPhone;
  final bool showCategory;
  final bool showMediaRow;
  static const _labelColor = Color(0xFF3F3F3F);

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return BlocBuilder<UpdateRestaurantCubit, UpdateRestaurantState>(
      buildWhen: (p, c) =>
          p.profileUrl != c.profileUrl ||
          p.bannerUrl != c.bannerUrl ||
          p.profileImage?.path != c.profileImage?.path ||
          p.bannerImage?.path != c.bannerImage?.path ||
          p.name != c.name ||
          p.email != c.email ||
          p.description != c.description ||
          p.address != c.address ||
          p.phone1 != c.phone1 ||
          p.phone2 != c.phone2 ||
          p.categories != c.categories ||
          p.selectedCategoryIds != c.selectedCategoryIds,
      builder: (context, state) {
        final cubit = context.read<UpdateRestaurantCubit>();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showMediaRow) ...[
              Row(
                children: [
                  Expanded(
                    child: UploadPickTile(
                      availableWidth: w,
                      title:
                          (state.profileImage != null ||
                              (state.profileUrl ?? '').isNotEmpty)
                          ? TranslationKeys.updateProfileImageSelected.tr(
                              context: context,
                            )
                          : TranslationKeys.updateUploadProfileImage.tr(
                              context: context,
                            ),
                      imagePath: state.profileImage?.path ?? state.profileUrl,
                      onPressed: cubit.pickProfileImage,
                      height: context.wOf(88, w),
                      useDashedBorder: true,
                      emptyIconAssetPath: 'assets/images/add_image_icon.png',
                      hideIconInLandscape: false,
                      onDeleteImage:
                          (state.profileImage != null ||
                              (state.profileUrl ?? '').isNotEmpty)
                          ? cubit.removeProfileImage
                          : null, //
                    ),
                  ),
                  SizedBox(width: context.wOf(8, w)),
                  Expanded(
                    flex: 2,
                    child: UploadPickTile(
                      availableWidth: w,
                      title:
                          (state.bannerImage != null ||
                              (state.bannerUrl ?? '').isNotEmpty)
                          ? TranslationKeys.updateBannerSelected.tr(
                              context: context,
                            )
                          : TranslationKeys.updateAddBannerImage.tr(
                              context: context,
                            ),
                      subtitle: TranslationKeys.updateOptimalDimensions.tr(
                        context: context,
                      ),
                      imagePath: state.bannerImage?.path ?? state.bannerUrl,
                      onPressed: cubit.pickBannerImage,
                      height: context.wOf(88, w),
                      useDashedBorder: true,
                      emptyIconAssetPath: 'assets/images/add_image_icon.png',
                      hideIconInLandscape: false,
                      onDeleteImage:
                          (state.bannerImage != null ||
                              (state.bannerUrl ?? '').isNotEmpty)
                          ? cubit.removeBannerImage
                          : null, //
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.wOf(12, w)),
            ],
            _FieldLabel(
              title: TranslationKeys.updateRestaurantNameLabel.tr(
                context: context,
              ),
              availableWidth: w,
            ),
            SizedBox(height: context.wOf(6, w)),
            CommonTextField(
              availableWidth: w,
              hint: TranslationKeys.updateRestaurantNameHint.tr(
                context: context,
              ),
              initialValue: state.name,
              onChanged: cubit.setName,
              validator: validateName,
              textSize: 14,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ), //
            ),
            SizedBox(height: context.wOf(10, w)),
            _FieldLabel(
              title: TranslationKeys.updateEmailLabel.tr(context: context),
              availableWidth: w,
            ),
            SizedBox(height: context.wOf(6, w)),
            CommonTextField(
              availableWidth: w,
              hint: TranslationKeys.authEmail.tr(context: context),
              initialValue: state.email,
              onChanged: cubit.setEmail,
              validator: validateEmail,
              keyboardType: TextInputType.emailAddress,
              textSize: 14,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ), //
            ),
            SizedBox(height: context.wOf(10, w)),
            _FieldLabel(
              title: TranslationKeys.updateDescriptionLabel.tr(
                context: context,
              ),
              availableWidth: w,
            ),
            SizedBox(height: context.wOf(6, w)),
            CommonTextField(
              availableWidth: w,
              hint: TranslationKeys.updateDescriptionLabel.tr(context: context),
              initialValue: state.description,
              onChanged: cubit.setDescription,
              minLines: 3,
              maxLines: 3,
              validator: (v) => validateRequired(
                v,
                field: TranslationKeys.updateDescriptionLabel.tr(
                  context: context,
                ),
              ),
              textSize: 14,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            SizedBox(height: context.wOf(10, w)),
            _FieldLabel(
              title: TranslationKeys.updateAddressLabel.tr(context: context),
              availableWidth: w,
            ),
            SizedBox(height: context.wOf(6, w)),
            CommonTextField(
              availableWidth: w,
              hint: TranslationKeys.updateAddressLabel.tr(context: context),
              initialValue: state.address,
              onChanged: cubit.setAddress,
              minLines: 3,
              maxLines: 3,
              validator: (v) => validateRequired(
                v,
                field: TranslationKeys.updateAddressLabel.tr(context: context),
              ),
              textSize: 14,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            SizedBox(height: context.wOf(10, w)),
            _FieldLabel(
              title: TranslationKeys.updatePhoneNumberLabel.tr(
                context: context,
              ),
              availableWidth: w,
            ),
            SizedBox(height: context.wOf(6, w)),
            Row(
              children: [
                Expanded(
                  child: CommonTextField(
                    availableWidth: w,
                    hint: TranslationKeys.authPhoneMask.tr(context: context),
                    initialValue: state.phone1,
                    onChanged: cubit.setPhone1,
                    mask: '+1 (###) ###-####',
                    keyboardType: TextInputType.phone,
                    validator: (value) => validateOptionalUsPhone(
                      value,
                      otherValue: state.phone2,
                    ),
                    textSize: 14,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ), //
                  ),
                ),
                SizedBox(width: context.wOf(8, w)),
                Expanded(
                  child: CommonTextField(
                    availableWidth: w,
                    hint: TranslationKeys.authPhoneMask.tr(context: context),
                    initialValue: state.phone2,
                    onChanged: cubit.setPhone2,
                    mask: '+1 (###) ###-####',
                    keyboardType: TextInputType.phone,
                    validator: (value) => validateOptionalUsPhone(
                      value,
                      otherValue: state.phone1,
                    ),
                    textSize: 14,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ), //
                  ),
                ),
              ],
            ),
            if (showCategory) ...[
              SizedBox(height: context.wOf(14, w)),
              _CategoryPreviewCard(
                availableWidth: w,
                categories: state.categories,
                selectedCategoryIds: state.selectedCategoryIds,
                onTapCategory: cubit.toggleCategory, //
              ), //
            ],
          ],
        );
      },
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.title, required this.availableWidth});

  final String title;
  final double availableWidth;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyle.regular14(
        context,
        aW: availableWidth,
        color: BasicInfoUpdateSection._labelColor,
      ),
    );
  }
}

class _CategoryPreviewCard extends StatelessWidget {
  const _CategoryPreviewCard({
    required this.availableWidth,
    required this.categories,
    required this.selectedCategoryIds,
    required this.onTapCategory, //
  });

  final double availableWidth;
  final List<VendorCategoryModel> categories;
  final List<int> selectedCategoryIds;
  final ValueChanged<int> onTapCategory;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.wOf(12, availableWidth)),
      decoration: BoxDecoration(
        color: StaticColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: StaticColors.cE2E2E2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            TranslationKeys.updateAddCategory.tr(context: context),
            style: AppTextStyle.semibold16(context, color: StaticColors.black),
          ),
          const Divider(height: 20),
          const SizedBox(height: 4),
          Wrap(
            spacing: 10,
            runSpacing: 6,
            children: categories.map((item) {
              final id = item.id;
              final selected = selectedCategoryIds.contains(id);
              return InkWell(
                onTap: () => onTapCategory(id),
                borderRadius: BorderRadius.circular(999),
                child: IntrinsicWidth(
                  child: Container(
                    height: 30,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: selected
                          ? StaticColors.primary
                          : StaticColors.white,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: selected
                            ? StaticColors.primary
                            : StaticColors.cE2E2E2,
                      ),
                    ),
                    child: Text(
                      item.name.toString(),
                      maxLines: 1,
                      softWrap: false,
                      style: AppTextStyle.medium12(
                        context,
                        color: selected
                            ? StaticColors.white
                            : StaticColors.c666666, //
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
