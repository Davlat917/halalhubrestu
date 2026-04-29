import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/extensions/size_extension.dart';
import 'package:halalhub_restaurant/core/widgets/common_textfield.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/create_restaurant/widgets/restaurant_common_widgets.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/create_restaurant/widgets/upload_pick_tile.dart';

class BasicInfoSection extends StatelessWidget {
  const BasicInfoSection({
    super.key,
    required this.availableWidth,
    required this.isTablet,
    required this.compact,
    required this.formKey,
    required this.profileImagePath,
    required this.bannerImagePath,
    required this.onPickProfileImage,
    required this.onPickBannerImage,
    this.onDeleteProfileImage,
    this.onDeleteBannerImage,
    required this.nameController,
    required this.emailController,
    required this.descriptionController,
    required this.addressController,
    required this.phonePrimaryController,
    required this.phoneSecondaryController,
    required this.validateName,
    required this.validateEmail,
    required this.validateRequired,
    required this.validateUsPhone,
    required this.continueButton,
    this.showCategorySection = false,
  });

  final double availableWidth;
  final bool isTablet;
  final bool compact;
  final GlobalKey<FormState> formKey;
  final String? profileImagePath;
  final String? bannerImagePath;
  final VoidCallback onPickProfileImage;
  final VoidCallback onPickBannerImage;
  final VoidCallback? onDeleteProfileImage;
  final VoidCallback? onDeleteBannerImage;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController descriptionController;
  final TextEditingController addressController;
  final TextEditingController phonePrimaryController;
  final TextEditingController phoneSecondaryController;
  final String? Function(String?) validateName;
  final String? Function(String?) validateEmail;
  final String? Function(String?, {required String field}) validateRequired;
  final String? Function(String?) validateUsPhone;
  final Widget continueButton;
  /// Faqat restoranni tahrirlash (`CreateRestaurantPage(isEdit: true)`) uchun.
  final bool showCategorySection;

  @override
  Widget build(BuildContext context) {
    final twoCols = isTablet && !compact;
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (twoCols)
            Row(
              children: [
                Expanded(
                  child: UploadPickTile(
                    availableWidth: availableWidth,
                    title: profileImagePath == null
                        ? TranslationKeys.updateUploadProfileImage.tr(
                            context: context,
                          )
                        : TranslationKeys.updateProfileImageSelected.tr(
                            context: context,
                          ),
                    onPressed: onPickProfileImage,
                    imagePath: profileImagePath,
                    onDeleteImage: profileImagePath == null
                        ? null
                        : onDeleteProfileImage,
                  ),
                ),
                SizedBox(width: context.wOf(10, availableWidth)),
                Expanded(
                  flex: 2,
                  child: UploadPickTile(
                    availableWidth: availableWidth,
                    title: bannerImagePath == null
                        ? TranslationKeys.updateAddBannerImage.tr(
                            context: context,
                          )
                        : TranslationKeys.updateBannerSelected.tr(
                            context: context,
                          ),
                    subtitle: TranslationKeys.updateOptimalDimensions.tr(
                      context: context,
                    ),
                    onPressed: onPickBannerImage,
                    imagePath: bannerImagePath,
                    onDeleteImage: bannerImagePath == null
                        ? null
                        : onDeleteBannerImage,
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: UploadPickTile(
                    availableWidth: availableWidth,
                    title: profileImagePath == null
                        ? TranslationKeys.updateUploadProfileImage.tr(
                            context: context,
                          )
                        : TranslationKeys.updateProfileImageSelected.tr(
                            context: context,
                          ),
                    onPressed: onPickProfileImage,
                    imagePath: profileImagePath,
                    onDeleteImage: profileImagePath == null
                        ? null
                        : onDeleteProfileImage,
                  ),
                ),
                SizedBox(width: context.wOf(8, availableWidth)),
                Expanded(
                  child: UploadPickTile(
                    availableWidth: availableWidth,
                    title: bannerImagePath == null
                        ? TranslationKeys.updateAddBannerImage.tr(
                            context: context,
                          )
                        : TranslationKeys.updateBannerSelected.tr(
                            context: context,
                          ),
                    subtitle: TranslationKeys.updateOptimalDimensions.tr(
                      context: context,
                    ),
                    onPressed: onPickBannerImage,
                    imagePath: bannerImagePath,
                    onDeleteImage: bannerImagePath == null
                        ? null
                        : onDeleteBannerImage,
                  ),
                ),
              ],
            ),
          SizedBox(height: context.wOf(12, availableWidth)),
          RestaurantFieldLabel(
            availableWidth: availableWidth,
            text: TranslationKeys.updateRestaurantNameLabel.tr(
              context: context,
            ),
          ),
          CommonTextField(
            controller: nameController,
            availableWidth: availableWidth,
            hint: TranslationKeys.updateRestaurantNameHint.tr(context: context),
            textSize: context.spOf(14, availableWidth),
            padding: EdgeInsets.symmetric(
              horizontal: context.wOf(12, availableWidth),
              vertical: context.wOf(10, availableWidth),
            ),
            validator: validateName,
          ),
          SizedBox(height: context.wOf(10, availableWidth)),
          RestaurantFieldLabel(
            availableWidth: availableWidth,
            text: TranslationKeys.updateEmailLabel.tr(context: context),
          ),
          CommonTextField(
            controller: emailController,
            availableWidth: availableWidth,
            hint: TranslationKeys.createRestaurantEmailExample.tr(
              context: context,
            ),
            textSize: context.spOf(14, availableWidth),
            padding: EdgeInsets.symmetric(
              horizontal: context.wOf(12, availableWidth),
              vertical: context.wOf(10, availableWidth),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: validateEmail,
          ),
          SizedBox(height: context.wOf(10, availableWidth)),
          RestaurantFieldLabel(
            availableWidth: availableWidth,
            text: TranslationKeys.updateDescriptionLabel.tr(context: context),
          ),
          CommonTextField(
            controller: descriptionController,
            availableWidth: availableWidth,
            hint: TranslationKeys.createRestaurantDescriptionHint.tr(
              context: context,
            ),
            textSize: context.spOf(14, availableWidth),
            padding: EdgeInsets.symmetric(
              horizontal: context.wOf(12, availableWidth),
              vertical: context.wOf(10, availableWidth),
            ),
            maxLines: 4,
            minLines: 3,
            validator: (v) => validateRequired(
              v,
              field: TranslationKeys.updateDescriptionLabel.tr(
                context: context,
              ),
            ),
          ),
          SizedBox(height: context.wOf(10, availableWidth)),
          RestaurantFieldLabel(
            availableWidth: availableWidth,
            text: TranslationKeys.updateAddressLabel.tr(context: context),
          ),
          CommonTextField(
            controller: addressController,
            availableWidth: availableWidth,
            hint: TranslationKeys.createRestaurantAddressHint.tr(
              context: context,
            ),
            textSize: context.spOf(14, availableWidth),
            padding: EdgeInsets.symmetric(
              horizontal: context.wOf(12, availableWidth),
              vertical: context.wOf(10, availableWidth),
            ),
            maxLines: 3,
            minLines: 2,
            validator: (v) => validateRequired(
              v,
              field: TranslationKeys.updateAddressLabel.tr(context: context),
            ),
          ),
          SizedBox(height: context.wOf(10, availableWidth)),
          RestaurantFieldLabel(
            availableWidth: availableWidth,
            text: TranslationKeys.updatePhoneNumberLabel.tr(context: context),
          ),
          Row(
            children: [
              Expanded(
                child: CommonTextField(
                  controller: phonePrimaryController,
                  availableWidth: availableWidth,
                  hint: TranslationKeys.authPhoneMask.tr(context: context),
                  textSize: context.spOf(14, availableWidth),
                  padding: EdgeInsets.symmetric(
                    horizontal: context.wOf(12, availableWidth),
                    vertical: context.wOf(10, availableWidth),
                  ),
                  keyboardType: TextInputType.phone,
                  mask: '+1 (###) ###-####',
                  validator: validateUsPhone,
                ),
              ),
              SizedBox(width: context.wOf(8, availableWidth)),
              Expanded(
                child: CommonTextField(
                  controller: phoneSecondaryController,
                  availableWidth: availableWidth,
                  hint: TranslationKeys.authPhoneMask.tr(context: context),
                  textSize: context.spOf(14, availableWidth),
                  padding: EdgeInsets.symmetric(
                    horizontal: context.wOf(12, availableWidth),
                    vertical: context.wOf(10, availableWidth),
                  ),
                  keyboardType: TextInputType.phone,
                  mask: '+1 (###) ###-####',
                  validator: (v) {
                    final raw = v?.trim() ?? '';
                    if (raw.isEmpty) return null;
                    return validateUsPhone(v);
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: context.wOf(16, availableWidth)),
          if (showCategorySection) ...[
            _CategoryPreviewCard(availableWidth: availableWidth),
            SizedBox(height: context.wOf(18, availableWidth)),
          ],
          continueButton,
        ],
      ),
    );
  }
}

class _CategoryPreviewCard extends StatelessWidget {
  const _CategoryPreviewCard({required this.availableWidth});

  final double availableWidth;

  @override
  Widget build(BuildContext context) {
    Widget chip(String label) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.wOf(12, availableWidth),
          vertical: context.wOf(6, availableWidth),
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF12A84E),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: context.spOf(12, availableWidth),
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.wOf(12, availableWidth)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E2E2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            TranslationKeys.updateAddCategory.tr(context: context),
            style: TextStyle(
              fontSize: context.spOf(16, availableWidth),
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: context.wOf(10, availableWidth)),
          const Divider(height: 1),
          SizedBox(height: context.wOf(12, availableWidth)),
          Container(
            height: context.wOf(46, availableWidth),
            padding: EdgeInsets.symmetric(
              horizontal: context.wOf(12, availableWidth),
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F6F6),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E2E2)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    TranslationKeys.updateSelectCategory.tr(context: context),
                    style: TextStyle(
                      color: const Color(0xFFB0B0B0),
                      fontSize: context.spOf(14, availableWidth),
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: const Color(0xFF9AA0A6),
                  size: context.wOf(22, availableWidth),
                ),
              ],
            ),
          ),
          SizedBox(height: context.wOf(12, availableWidth)),
          Wrap(
            spacing: context.wOf(8, availableWidth),
            runSpacing: context.wOf(8, availableWidth),
            children: [
              chip('Indian foods'),
              chip('Uzbek foods'),
              chip('Turkish foods'),
              chip('Fast foods'),
              chip('Vegetarian'),
            ],
          ),
        ],
      ),
    );
  }
}
