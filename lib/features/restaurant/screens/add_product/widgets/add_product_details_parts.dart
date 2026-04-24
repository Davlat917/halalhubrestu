import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/widgets/common_textfield.dart';

double? parsePriceValue(String? raw) {
  if (raw == null) return null;
  var cleaned = raw.trim();
  if (cleaned.isEmpty) return null;

  cleaned = cleaned
      .replaceAll(' ', '')
      .replaceAll('\$', '')
      .replaceAll(',', '.')
      .replaceAll(RegExp(r'[^0-9.]'), '');

  final firstDot = cleaned.indexOf('.');
  if (firstDot != -1) {
    final before = cleaned.substring(0, firstDot + 1);
    final after = cleaned.substring(firstDot + 1).replaceAll('.', '');
    cleaned = '$before$after';
  }

  return double.tryParse(cleaned);
}

int? parsePreparationTimeMinutes(String? raw) {
  if (raw == null) return null;
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return null;
  final match = RegExp(r'\d+').firstMatch(trimmed);
  if (match == null) return null;
  return int.tryParse(match.group(0)!);
}

class FieldLabel extends StatelessWidget {
  const FieldLabel({super.key, required this.text, this.required = false});

  final String text;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Color(0xFF4A4A4A),
          fontSize: 30 / 2,
          fontWeight: FontWeight.w400,
        ),
        children: required
            ? const [
                TextSpan(
                  text: '*',
                  style: TextStyle(color: Colors.red),
                ),
              ]
            : const [],
      ),
    );
  }
}

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

class ChipWrapSelector extends StatelessWidget {
  const ChipWrapSelector({
    super.key,
    required this.ids,
    required this.labels,
    required this.selectedIds,
    required this.onSelected,
    required this.chipRadius,
  });

  final List<int> ids;
  final List<String> labels;
  final Set<int> selectedIds;
  final void Function(int id, bool selected) onSelected;
  final double chipRadius;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (int i = 0; i < ids.length; i++)
          _ChoiceChip(
            id: ids[i],
            label: labels[i],
            selected: selectedIds.contains(ids[i]),
            onSelected: onSelected,
            chipRadius: chipRadius,
          ),
      ],
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.id,
    required this.label,
    required this.selected,
    required this.onSelected,
    required this.chipRadius,
  });

  final int id;
  final String label;
  final bool selected;
  final void Function(int id, bool selected) onSelected;
  final double chipRadius;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : const Color(0xFF4A4A4A),
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
      selected: selected,
      showCheckmark: false,
      selectedColor: const Color(0xFF0DA84A),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(chipRadius),
        side: BorderSide(
          color: selected ? const Color(0xFF0DA84A) : const Color(0xFFE2E2E2),
        ),
      ),
      onSelected: (v) => onSelected(id, v),
    );
  }
}
