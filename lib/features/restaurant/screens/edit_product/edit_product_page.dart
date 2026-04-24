import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/di/injection.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/core/widgets/feedback/global_feedback_dialog.dart';
import 'package:halalhub_restaurant/features/restaurant/data/repositories/restaurant_repo.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/add_product/bloc/add_product_bloc.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/add_product/mixins/add_product_form_mixin.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/add_product/sections/add_product_form_section.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/add_product/widgets/add_product_details_parts.dart';
import 'package:image_picker/image_picker.dart';

@RoutePage()
class EditProductPage extends StatelessWidget {
  const EditProductPage({
    super.key,
    required this.vendorId,
    required this.productId,
    required this.initialName,
    required this.initialDescription,
    required this.initialPrice,
    required this.initialPreparationTime,
    required this.initialIsAvailable,
    required this.initialCategoryIds,
    required this.initialIngredientTitles,
    required this.initialImageUrls,
    required this.initialImageIds,
    this.initialDiscountTitle,
    this.initialDiscountPercent,
  });

  final int vendorId;
  final int productId;
  final String initialName;
  final String? initialDescription;
  final String? initialPrice;
  final int? initialPreparationTime;
  final bool initialIsAvailable;
  final List<int> initialCategoryIds;
  final List<String> initialIngredientTitles;
  final List<String> initialImageUrls;
  final List<int> initialImageIds;
  final String? initialDiscountTitle;
  final double? initialDiscountPercent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StaticColors.cF8F8F8,
      appBar: AppBar(
        title: Text(TranslationKeys.editProductTitle.tr(context: context)),
      ),
      body: BlocProvider(
        create: (_) =>
            AddProductBloc(getIt<RestaurantRepo>())..loadInitialData(),
        child: _EditProductBody(
          vendorId: vendorId,
          productId: productId,
          initialName: initialName,
          initialDescription: initialDescription,
          initialPrice: initialPrice,
          initialPreparationTime: initialPreparationTime,
          initialIsAvailable: initialIsAvailable,
          initialCategoryIds: initialCategoryIds,
          initialIngredientTitles: initialIngredientTitles,
          initialImageUrls: initialImageUrls,
          initialImageIds: initialImageIds,
          initialDiscountTitle: initialDiscountTitle,
          initialDiscountPercent: initialDiscountPercent,
        ),
      ),
    );
  }
}

class _EditProductBody extends StatefulWidget {
  const _EditProductBody({
    required this.vendorId,
    required this.productId,
    required this.initialName,
    required this.initialDescription,
    required this.initialPrice,
    required this.initialPreparationTime,
    required this.initialIsAvailable,
    required this.initialCategoryIds,
    required this.initialIngredientTitles,
    required this.initialImageUrls,
    required this.initialImageIds,
    required this.initialDiscountTitle,
    required this.initialDiscountPercent,
  });

  final int vendorId;
  final int productId;
  final String initialName;
  final String? initialDescription;
  final String? initialPrice;
  final int? initialPreparationTime;
  final bool initialIsAvailable;
  final List<int> initialCategoryIds;
  final List<String> initialIngredientTitles;
  final List<String> initialImageUrls;
  final List<int> initialImageIds;
  final String? initialDiscountTitle;
  final double? initialDiscountPercent;

  @override
  State<_EditProductBody> createState() => _EditProductBodyState();
}

class _EditProductBodyState extends State<_EditProductBody>
    with AddProductFormMixin {
  final ImagePicker _picker = ImagePicker();
  bool _seededInitialSelection = false;
  late final List<String> _editableInitialImageUrls;
  late final List<int> _editableInitialImageIds;
  final Set<int> _deletedExistingImageIds = <int>{};

  @override
  void initState() {
    super.initState();
    nameController.text = widget.initialName;
    descriptionController.text = widget.initialDescription ?? '';
    priceController.text = widget.initialPrice ?? '';
    preparationController.text =
        widget.initialPreparationTime?.toString() ?? '';
    if (widget.initialDiscountPercent != null) {
      discountController.text = widget.initialDiscountPercent!.toString();
    }
    if (widget.initialDiscountTitle != null) {
      deletedImageIdsController.text = widget.initialDiscountTitle!;
    }
    _editableInitialImageUrls = List<String>.from(widget.initialImageUrls);
    _editableInitialImageIds = List<int>.from(widget.initialImageIds);
  }

  String? _buildDiscountsJson() {
    final primary = nonEmptyOrNull(discountController.text);
    final secondary = nonEmptyOrNull(deletedImageIdsController.text);
    // Edit flow: if both fields are empty, send [] to clear existing discounts.
    if (primary == null && secondary == null) return '[]';

    final percentMatch = RegExp(r'(\d+(?:[.,]\d+)?)').firstMatch(primary ?? '');
    final rawPercent = percentMatch?.group(1)?.replaceAll(',', '.');
    final percent = double.tryParse(rawPercent ?? '') ?? 0;
    final title = secondary ?? '';

    final normalizedPercent = percent % 1 == 0 ? percent.toInt() : percent;
    return jsonEncode({'percent': normalizedPercent, 'title': title});
  }

  Future<void> _pickImages() async {
    final files = await _picker.pickMultiImage(imageQuality: 85);
    if (!mounted || files.isEmpty) return;
    final bloc = context.read<AddProductBloc>();
    if (bloc.state.images.length >= AddProductBloc.maxImages) return;
    bloc.addImages(files);
  }

  Future<void> _submit() async {
    final bloc = context.read<AddProductBloc>();
    if (!formKey.currentState!.validate()) return;
    final preparationMinutes = parsePreparationTimeMinutes(
      preparationController.text,
    );
    if (preparationMinutes == null) return;

    await bloc.submitEdit(
      vendorId: widget.vendorId,
      productId: widget.productId,
      name: nameController.text.trim(),
      preparationTime: preparationMinutes,
      price: parsePriceValue(priceController.text),
      description: nonEmptyOrNull(descriptionController.text),
      discountsJson: _buildDiscountsJson(),
      deletedImageIds: _deletedExistingImageIds.isEmpty
          ? null
          : jsonEncode(_deletedExistingImageIds.toList(growable: false)),
    );

    if (!mounted) return;
    final blocState = context.read<AddProductBloc>().state;
    if (blocState.success) {
      showGlobalSuccessFeedback(
        context,
        title: TranslationKeys.productUpdatedTitle.tr(context: context),
        message: TranslationKeys.productUpdatedMessage.tr(context: context),
      );
      context.router.maybePop();
    } else if (blocState.errorMessage != null) {
      showGlobalFailureFeedback(
        context,
        title: TranslationKeys.productUpdateFailedTitle.tr(context: context),
        message: blocState.errorMessage!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddProductBloc, AddProductState>(
      builder: (context, state) {
        if (!state.categoriesReady || !state.ingredientsReady) {
          if (state.isLoadingCategories || state.isLoadingIngredients) {
            return const Center(
              child: CircularProgressIndicator(color: StaticColors.primary),
            );
          }
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  state.errorMessage ??
                      TranslationKeys.dataLoadFailed.tr(context: context),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () =>
                      context.read<AddProductBloc>().loadInitialData(),
                  child: Text(TranslationKeys.retry.tr(context: context)),
                ),
              ],
            ),
          );
        }

        if (!_seededInitialSelection) {
          _seededInitialSelection = true;
          final ingredientTitleSet = widget.initialIngredientTitles
              .map((e) => e.trim().toLowerCase())
              .where((e) => e.isNotEmpty)
              .toSet();
          final ingredientIds = state.ingredients
              .where(
                (e) =>
                    ingredientTitleSet.contains(e.title.trim().toLowerCase()),
              )
              .map((e) => e.id)
              .toSet();
          context.read<AddProductBloc>().hydrateForEdit(
            selectedCategoryIds: widget.initialCategoryIds.toSet(),
            selectedIngredientIds: ingredientIds,
            isAvailable: widget.initialIsAvailable,
          );
        }

        return AddProductFormSection(
          formKey: formKey,
          state: state,
          nameController: nameController,
          descriptionController: descriptionController,
          priceController: priceController,
          preparationController: preparationController,
          ingredientsController: ingredientsController,
          discountController: discountController,
          deletedImageIdsController: deletedImageIdsController,
          onSubmit: _submit,
          onPickImages: _pickImages,
          onRemoveImage: (index) =>
              context.read<AddProductBloc>().removeImageAt(index),
          onRemoveInitialImage: (index) {
            if (index < 0 || index >= _editableInitialImageUrls.length) return;
            setState(() {
              _editableInitialImageUrls.removeAt(index);
              if (index < _editableInitialImageIds.length) {
                _deletedExistingImageIds.add(
                  _editableInitialImageIds.removeAt(index),
                );
              }
            });
          },
          initialImageUrls: _editableInitialImageUrls,
          onToggleCategory: (id, selected) {
            context.read<AddProductBloc>().toggleCategory(id, selected);
            formKey.currentState?.validate();
          },
          onToggleIngredient: (id, selected) {
            context.read<AddProductBloc>().toggleIngredient(id, selected);
            formKey.currentState?.validate();
          },
          onChangeAvailability: (value) =>
              context.read<AddProductBloc>().setAvailability(value),
        );
      },
    );
  }
}
