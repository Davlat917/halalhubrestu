import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/core/widgets/common_textfield.dart';
import 'package:halalhub_restaurant/core/widgets/custom_button.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/add_product/bloc/add_product_bloc.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/add_product/widgets/add_product_details_parts.dart';

class AddProductDetailsSection extends StatelessWidget {
  const AddProductDetailsSection({
    super.key,
    required this.state,
    required this.nameController,
    required this.descriptionController,
    required this.priceController,
    required this.preparationController,
    required this.ingredientsController,
    required this.discountController,
    required this.deletedImageIdsController,
    required this.onSubmit,
    required this.onToggleCategory,
    required this.onToggleIngredient,
    required this.onChangeAvailability,
    this.showSelectionSummaryFields = true,
  });

  final AddProductState state;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController priceController;
  final TextEditingController preparationController;
  final TextEditingController ingredientsController;
  final TextEditingController discountController;
  final TextEditingController deletedImageIdsController;
  final VoidCallback onSubmit;
  final void Function(int id, bool selected) onToggleCategory;
  final void Function(int id, bool selected) onToggleIngredient;
  final ValueChanged<bool> onChangeAvailability;
  final bool showSelectionSummaryFields;
  static const _singlePadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 13,
  );
  static const _chipRadius = 100.0;

  @override
  Widget build(BuildContext context) {
    final selectedCategoryText = state.selectedCategoryIds.isEmpty
        ? TranslationKeys.productCategorySelect.tr(context: context)
        : state.categories
              .where((e) => state.selectedCategoryIds.contains(e.id))
              .map((e) => e.name)
              .join(', ');
    final selectedIngredientText = state.selectedIngredientIds.isEmpty
        ? TranslationKeys.productIngredientSelect.tr(context: context)
        : '${state.selectedIngredientIds.length} selected';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          TranslationKeys.productFoodDetails.tr(context: context),
          style: AppTextStyle.medium18(context),
        ),
        const SizedBox(height: 12),
        LabeledFixedField(
          label: TranslationKeys.productFoodName.tr(context: context),
          required: true,
          child: CommonTextField(
            controller: nameController,
            hint: TranslationKeys.productFoodName.tr(context: context),
            padding: _singlePadding,
            textSize: 14,
            textFontWeight: FontWeight.w400,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? TranslationKeys.productFoodNameRequired.tr(context: context)
                : null, //
          ),
        ),
        const SizedBox(height: 12),
        FieldLabel(
          text: TranslationKeys.productDescription.tr(context: context),
          required: true,
        ),
        const SizedBox(height: 8),
        CommonTextField(
          controller: descriptionController,
          hint: TranslationKeys.clipsDescribeFood.tr(context: context),
          minLines: 3,
          maxLines: 3,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textSize: 14,
          textFontWeight: FontWeight.w400,
          validator: (v) => (v == null || v.trim().isEmpty)
              ? TranslationKeys.productDescriptionRequired.tr(context: context)
              : null, //
        ),
        const SizedBox(height: 12),
        PricePrepRow(
          priceController: priceController,
          preparationController: preparationController,
          singlePadding: _singlePadding, //
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF5FBF7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2F2E8)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.restaurant_rounded,
                    size: 18,
                    color: StaticColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    TranslationKeys.productIngredient.tr(context: context),
                    style: AppTextStyle.medium14(context, color: StaticColors.black),
                  ),
                  Text(
                    '*',
                    style: AppTextStyle.medium14(context, color: Colors.red),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (showSelectionSummaryFields) ...[
                SelectionField(
                  label: TranslationKeys.productIngredient.tr(context: context),
                  required: true,
                  text: selectedIngredientText,
                  controller: ingredientsController,
                  singlePadding: _singlePadding,
                  validator: (_) => state.selectedIngredientIds.isEmpty
                      ? TranslationKeys.productIngredientRequired.tr(context: context)
                      : null, //
                ),
                const SizedBox(height: 10),
              ],
              if (state.isLoadingIngredients)
                const LinearProgressIndicator()
              else
                ChipWrapSelector(
                  labels: state.ingredients
                      .map((e) => e.title)
                      .toList(growable: false),
                  selectedIds: state.selectedIngredientIds,
                  ids: state.ingredients.map((e) => e.id).toList(growable: false),
                  onSelected: onToggleIngredient,
                  chipRadius: _chipRadius, //
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F8F8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: StaticColors.cE2E2E2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.grid_view_rounded,
                    size: 17,
                    color: StaticColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    TranslationKeys.productCategory.tr(context: context),
                    style: AppTextStyle.medium14(context, color: StaticColors.black),
                  ),
                  Text(
                    '*',
                    style: AppTextStyle.medium14(context, color: Colors.red),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (showSelectionSummaryFields) ...[
                SelectionField(
                  label: TranslationKeys.productCategory.tr(context: context),
                  required: true,
                  text: selectedCategoryText,
                  singlePadding: _singlePadding,
                  validator: (_) => state.selectedCategoryIds.isEmpty
                      ? TranslationKeys.productCategoryRequired.tr(context: context)
                      : null, //
                ),
                const SizedBox(height: 10),
              ],
              if (state.isLoadingCategories)
                const LinearProgressIndicator()
              else
                ChipWrapSelector(
                  labels: state.categories.map((e) => e.name).toList(growable: false),
                  selectedIds: state.selectedCategoryIds,
                  ids: state.categories.map((e) => e.id).toList(growable: false),
                  onSelected: onToggleCategory,
                  chipRadius: _chipRadius, //
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        FieldLabel(text: TranslationKeys.productDiscount.tr(context: context)),
        const SizedBox(height: 8),
        DiscountRow(
          discountController: discountController,
          deletedImageIdsController: deletedImageIdsController,
          singlePadding: _singlePadding, //
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          value: state.isAvailable,
          onChanged: onChangeAvailability,
          activeThumbColor: Colors.white,
          activeTrackColor: const Color(0xFF0DA84A),
          title: Text(
            TranslationKeys.productAvailability.tr(context: context),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          ),
          contentPadding: EdgeInsets.zero,
        ),
        const SizedBox(height: 16),
        CustomButton(
          label: state.isSubmitting
              ? TranslationKeys.productUploading.tr(context: context)
              : TranslationKeys.productAdd.tr(context: context),
          onPressed: state.isSubmitting ? null : onSubmit,
          height: 50, //
        ),
      ],
    );
  }
}
