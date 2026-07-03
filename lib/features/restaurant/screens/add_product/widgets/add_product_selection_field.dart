import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/widgets/common_textfield.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/add_product/widgets/add_product_labeled_fixed_field.dart';

class SelectionField extends StatelessWidget {
  const SelectionField({
    super.key,
    required this.label,
    required this.text,
    required this.singlePadding,
    this.required = false,
    this.controller,
    this.validator,
  });

  final String label;
  final bool required;
  final String text;
  final TextEditingController? controller;
  final EdgeInsets singlePadding;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return LabeledFixedField(
      label: label,
      required: required,
      child: CommonTextField(
        controller: controller,
        hint: text,
        readOnly: true,
        padding: singlePadding,
        textSize: 14,
        textFontWeight: FontWeight.w400,
        suffix: const Icon(Icons.keyboard_arrow_down_rounded),
        validator: validator,
      ),
    );
  }
}
