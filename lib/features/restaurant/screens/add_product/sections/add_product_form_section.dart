import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/add_product/bloc/add_product_bloc.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/add_product/widgets/add_product_details_section.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/add_product/widgets/add_product_image_section.dart';

class AddProductFormSection extends StatelessWidget {
  const AddProductFormSection({
    super.key,
    required this.formKey,
    required this.state,
    required this.nameController,
    required this.descriptionController,
    required this.priceController,
    required this.preparationController,
    required this.ingredientsController,
    required this.discountController,
    required this.deletedImageIdsController,
    required this.onSubmit,
    required this.onPickImages,
    required this.onRemoveImage,
    this.onRemoveInitialImage,
    required this.onToggleCategory,
    required this.onToggleIngredient,
    required this.onChangeAvailability,
    this.initialImageUrls = const [],
    this.showSelectionSummaryFields = true,
  });

  final GlobalKey<FormState> formKey;
  final AddProductState state;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController priceController;
  final TextEditingController preparationController;
  final TextEditingController ingredientsController;
  final TextEditingController discountController;
  final TextEditingController deletedImageIdsController;
  final VoidCallback onSubmit;
  final Future<void> Function() onPickImages;
  final ValueChanged<int> onRemoveImage;
  final ValueChanged<int>? onRemoveInitialImage;
  final void Function(int id, bool selected) onToggleCategory;
  final void Function(int id, bool selected) onToggleIngredient;
  final ValueChanged<bool> onChangeAvailability;
  final List<String> initialImageUrls;
  final bool showSelectionSummaryFields;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 980;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: StaticColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: StaticColors.cE2E2E2),
          ),
          child: isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AddProductImageSection(
                        images: state.images,
                        initialImageUrls: initialImageUrls,
                        onPick: onPickImages,
                        onRemoveImage: onRemoveImage,
                        onRemoveInitialImage: onRemoveInitialImage,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: AddProductDetailsSection(
                        state: state,
                        nameController: nameController,
                        descriptionController: descriptionController,
                        priceController: priceController,
                        preparationController: preparationController,
                        ingredientsController: ingredientsController,
                        discountController: discountController,
                        deletedImageIdsController: deletedImageIdsController,
                        onSubmit: onSubmit,
                        onToggleCategory: onToggleCategory,
                        onToggleIngredient: onToggleIngredient,
                        onChangeAvailability: onChangeAvailability,
                        showSelectionSummaryFields: showSelectionSummaryFields,
                      ),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AddProductImageSection(
                      images: state.images,
                      initialImageUrls: initialImageUrls,
                      onPick: onPickImages,
                      onRemoveImage: onRemoveImage,
                      onRemoveInitialImage: onRemoveInitialImage,
                    ),
                    const SizedBox(height: 20),
                    AddProductDetailsSection(
                      state: state,
                      nameController: nameController,
                      descriptionController: descriptionController,
                      priceController: priceController,
                      preparationController: preparationController,
                      ingredientsController: ingredientsController,
                      discountController: discountController,
                      deletedImageIdsController: deletedImageIdsController,
                      onSubmit: onSubmit,
                      onToggleCategory: onToggleCategory,
                      onToggleIngredient: onToggleIngredient,
                      onChangeAvailability: onChangeAvailability,
                      showSelectionSummaryFields: showSelectionSummaryFields,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
