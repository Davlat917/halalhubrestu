import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/widgets/common_textfield.dart';

class DiscountRow extends StatelessWidget {
  const DiscountRow({
    super.key,
    required this.discountController,
    required this.deletedImageIdsController,
    required this.singlePadding,
  });

  final TextEditingController discountController;
  final TextEditingController deletedImageIdsController;
  final EdgeInsets singlePadding;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 50,
            child: CommonTextField(
              controller: discountController,
              hint: TranslationKeys.productExamplePercent.tr(context: context),
              padding: singlePadding,
              textSize: 14,
              textFontWeight: FontWeight.w400,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatter: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9\.,]')),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 50,
            child: CommonTextField(
              controller: deletedImageIdsController,
              hint: TranslationKeys.productExampleDeal.tr(context: context),
              padding: singlePadding,
              textSize: 14,
              textFontWeight: FontWeight.w400,
              keyboardType: TextInputType.text,
            ),
          ),
        ),
      ],
    );
  }
}
