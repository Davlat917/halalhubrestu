import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/extensions/size_extension.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/core/widgets/circle_btn_widget.dart';

class UpdateRestaurantTopBar extends StatelessWidget {
  const UpdateRestaurantTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final isLarge = w >= 900;
    const buttonSize = 32.0;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.wOf(12, w),
        vertical: context.wOf(8, w),
      ),
      decoration: const BoxDecoration(
        color: StaticColors.white,
        border: Border(bottom: BorderSide(color: StaticColors.cE2E2E2)),
      ),
      child: Row(
        children: [
          CircleBtnWidget(
            height: buttonSize,
            width: buttonSize,
            radius: 40,
            padding: const EdgeInsets.all(8),
            bgColor: StaticColors.backgroundColor, //
          ),
          Expanded(
            child: Center(
              child: Text(
                TranslationKeys.createRestaurantUpdateTitle.tr(
                  context: context,
                ),
                style: AppTextStyle.semibold16(
                  context,
                  size: isLarge ? 20 : 16,
                  color: StaticColors.black,
                ),
              ),
            ),
          ),
          const SizedBox(width: buttonSize),
        ],
      ),
    );
  }
}
