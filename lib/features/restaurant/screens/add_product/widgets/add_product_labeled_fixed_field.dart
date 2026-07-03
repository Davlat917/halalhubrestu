import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/add_product/widgets/add_product_field_label.dart';

class LabeledFixedField extends StatelessWidget {
  const LabeledFixedField({
    super.key,
    required this.label,
    required this.child,
    this.required = false,
  });

  final String label;
  final bool required;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FieldLabel(text: label, required: required),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
