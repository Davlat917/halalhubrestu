import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/core/widgets/common_textfield.dart';
import 'package:halalhub_restaurant/core/widgets/custom_button.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/add_product/bloc/add_product_bloc.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/add_product/widgets/add_product_details_parts.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/add_product/widgets/add_product_dimension_modifier_selector.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/add_product/widgets/add_product_expansion_selection_field.dart';

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
    required this.onToggleRecommendation,
    required this.onAddModifierGroup,
    required this.onUpdateModifierGroup,
    required this.onRemoveModifierGroup,
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
  final void Function(int id, bool selected) onToggleRecommendation;
  final ValueChanged<AddProductModifierGroup> onAddModifierGroup;
  final void Function(int index, AddProductModifierGroup group)
  onUpdateModifierGroup;
  final ValueChanged<int> onRemoveModifierGroup;
  final ValueChanged<bool> onChangeAvailability;
  final bool showSelectionSummaryFields;
  static const _singlePadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 13,
  );

  @override
  Widget build(BuildContext context) {
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
        ExpansionSelectionField(
          label: TranslationKeys.productIngredient.tr(context: context),
          hint: TranslationKeys.productIngredientSelect.tr(context: context),
          ids: state.ingredients.map((e) => e.id).toList(growable: false),
          labels: state.ingredients.map((e) => e.title).toList(growable: false),
          selectedIds: state.selectedIngredientIds,
          controlType: ExpansionSelectionControlType.checkbox,
          required: true,
          isLoading: state.isLoadingIngredients,
          validator: (_) => state.selectedIngredientIds.isEmpty
              ? TranslationKeys.productIngredientRequired.tr(context: context)
              : null,
          onSelected: onToggleIngredient,
        ),
        const SizedBox(height: 20),
        ExpansionSelectionField(
          label: TranslationKeys.productCategory.tr(context: context),
          hint: TranslationKeys.productCategorySelect.tr(context: context),
          ids: state.categories.map((e) => e.id).toList(growable: false),
          labels: state.categories.map((e) => e.name).toList(growable: false),
          selectedIds: state.selectedCategoryIds,
          controlType: ExpansionSelectionControlType.radio,
          required: true,
          isLoading: state.isLoadingCategories,
          validator: (_) => state.selectedCategoryIds.isEmpty
              ? TranslationKeys.productCategoryRequired.tr(context: context)
              : null,
          onSelected: onToggleCategory,
        ),
        const SizedBox(height: 20),
        AddProductDimensionModifierSelector(
          dishName: nameController.text,
          groups: state.modifierGroups,
          onAddModifierGroup: onAddModifierGroup,
          onUpdateModifierGroup: onUpdateModifierGroup,
          onRemoveModifierGroup: onRemoveModifierGroup,
        ),
        const SizedBox(height: 20),
        ExpansionSelectionField(
          label: 'Recommendations',
          hint: 'Select recommendations',
          ids: state.recommendationProducts
              .map((e) => e.id)
              .toList(growable: false),
          labels: state.recommendationProducts
              .map((e) => e.name)
              .toList(growable: false),
          selectedIds: state.selectedRecommendationIds,
          controlType: ExpansionSelectionControlType.checkbox,
          onSelected: onToggleRecommendation,
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              TranslationKeys.productAvailability.tr(context: context),
              style: AppTextStyle.regular16(context),
            ),
            Switch(
              value: state.isAvailable,
              onChanged: onChangeAvailability,
              activeThumbColor: StaticColors.white,
              activeTrackColor: StaticColors.primary,
            ),
          ],
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
