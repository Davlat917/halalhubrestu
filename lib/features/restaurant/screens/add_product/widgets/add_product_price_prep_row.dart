import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/widgets/common_textfield.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/add_product/utils/add_product_input_parsers.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/add_product/widgets/add_product_labeled_fixed_field.dart';

class PricePrepRow extends StatelessWidget {
  const PricePrepRow({
    super.key,
    required this.priceController,
    required this.preparationController,
    required this.singlePadding,
  });

  final TextEditingController priceController;
  final TextEditingController preparationController;
  final EdgeInsets singlePadding;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: LabeledFixedField(
            label: TranslationKeys.productPrice.tr(context: context),
            required: true,
            child: CommonTextField(
              controller: priceController,
              hint: TranslationKeys.productExamplePrice.tr(context: context),
              padding: singlePadding,
              textSize: 14,
              textFontWeight: FontWeight.w400,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return TranslationKeys.productRequired.tr(context: context);
                }
                return parsePriceValue(v) == null
                    ? TranslationKeys.productEnterNumber.tr(context: context)
                    : null;
              },
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: LabeledFixedField(
            label: TranslationKeys.productPreparationTime.tr(context: context),
            required: true,
            child: CommonTextField(
              controller: preparationController,
              hint: TranslationKeys.productExampleMin.tr(context: context),
              padding: singlePadding,
              textSize: 14,
              textFontWeight: FontWeight.w400,
              keyboardType: TextInputType.text,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return TranslationKeys.productRequired.tr(context: context);
                }
                return parsePreparationTimeMinutes(v) == null
                    ? TranslationKeys.productExamplePreparationTime.tr(
                        context: context,
                      )
                    : null;
              },
            ),
          ),
        ),
      ],
    );
  }
}
