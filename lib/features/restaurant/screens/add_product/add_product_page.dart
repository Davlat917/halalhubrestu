import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/di/injection.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/core/widgets/display/display.dart';
import 'package:halalhub_restaurant/core/widgets/responsive_section.dart';
import 'package:halalhub_restaurant/core/widgets/shimmer_item.dart';
import 'package:halalhub_restaurant/features/restaurant/data/repositories/restaurant_repo.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/add_product/bloc/add_product_bloc.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/add_product/mixins/add_product_form_mixin.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/add_product/sections/add_product_form_section.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/add_product/widgets/add_product_details_parts.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_profile/navigation/vendor_nav_item.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_profile/widgets/vendor_shell_layout.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';

class AddProductPage extends ResponsiveSection {
  const AddProductPage({super.key});

  @override
  Widget buildMobile(BuildContext context) =>
      const _AddProductScaffold(isTablet: false);

  @override
  Widget buildTablet(BuildContext context) =>
      const _AddProductScaffold(isTablet: true);

  @override
  Widget buildDesktop(BuildContext context) => buildTablet(context);
}

class _AddProductScaffold extends StatelessWidget {
  const _AddProductScaffold({required this.isTablet});

  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    return VendorShellLayout(
      isTablet: isTablet,
      selectedNavItem: VendorNavItem.addProduct,
      body: const AddProductBody(),
    );
  }
}

class AddProductBody extends StatelessWidget {
  const AddProductBody({super.key, this.bloc});

  final AddProductBloc? bloc;

  @override
  Widget build(BuildContext context) {
    final providedBloc = bloc;
    if (providedBloc != null) {
      return BlocProvider.value(
        value: providedBloc,
        child: const _AddProductFormBody(),
      );
    }
    return BlocProvider(
      create: (_) => AddProductBloc(getIt<RestaurantRepo>())..loadInitialData(),
      child: const _AddProductFormBody(),
    );
  }
}

class _AddProductFormBody extends StatefulWidget {
  const _AddProductFormBody();

  @override
  State<_AddProductFormBody> createState() => _AddProductBodyState();
}

class _AddProductBodyState extends State<_AddProductFormBody>
    with AddProductFormMixin {
  final ImagePicker _picker = ImagePicker();
  final Display _display = getIt<Display>();

  String? _buildDiscountsJson() {
    final primary = nonEmptyOrNull(discountController.text);
    final secondary = nonEmptyOrNull(deletedImageIdsController.text);
    if (primary == null && secondary == null) return null;
    final percentMatch = RegExp(r'(\d+(?:[.,]\d+)?)').firstMatch(primary ?? '');
    final rawPercent = percentMatch?.group(1)?.replaceAll(',', '.');
    final percent = double.tryParse(rawPercent ?? '') ?? 0;
    final title = secondary ?? '';
    return jsonEncode([
      {'percent': percent, 'title': title},
    ]);
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
    final state = bloc.state;
    if (bloc.state.images.isEmpty) {
      _display.warning(
        TranslationKeys.productImageRequiredMessage.tr(context: context),
        TranslationKeys.productImageRequiredTitle.tr(context: context),
      );
      return;
    }
    if (state.selectedIngredientIds.isEmpty) {
      _display.warning(
        TranslationKeys.productIngredientRequired.tr(context: context),
      );
      return;
    }
    if (state.selectedCategoryIds.isEmpty) {
      _display.warning(
        TranslationKeys.productCategoryRequired.tr(context: context),
      );
      return;
    }

    if (!formKey.currentState!.validate()) return;
    final preparationMinutes = parsePreparationTimeMinutes(
      preparationController.text,
    );
    if (preparationMinutes == null) return;

    await bloc.submit(
      name: nameController.text.trim(),
      preparationTime: preparationMinutes,
      price: parsePriceValue(priceController.text),
      description: nonEmptyOrNull(descriptionController.text),
      discountsJson: _buildDiscountsJson(),
      deletedImageIds: null,
    );

    if (!mounted) return;
    final blocState = context.read<AddProductBloc>().state;
    if (blocState.success) {
      _display.success(
        TranslationKeys.productAddedMessage.tr(context: context),
        TranslationKeys.productAddedTitle.tr(context: context),
      );
      formKey.currentState?.reset();
      clearInputs();
      context.read<AddProductBloc>().clearFormState();
    } else if (blocState.errorMessage != null) {
      _display.error(
        blocState.errorMessage!,
        TranslationKeys.productAddFailedTitle.tr(context: context),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddProductBloc, AddProductState>(
      builder: (context, state) {
        if (!state.categoriesReady || !state.ingredientsReady) {
          if (state.isLoadingCategories || state.isLoadingIngredients) {
            return const _AddProductLoadingSkeleton();
          }
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  state.errorMessage ??
                      TranslationKeys.productCategoriesLoadFailed.tr(
                        context: context,
                      ),
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
          showSelectionSummaryFields: false,
        );
      },
    );
  }
}

class _AddProductLoadingSkeleton extends StatelessWidget {
  const _AddProductLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: StaticColors.cE2E2E2,
      highlightColor: Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 900;
                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _imageSkeleton(),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: _detailsSkeleton(),
                      ),
                    ],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _imageSkeleton(),
                    const SizedBox(height: 20),
                    _detailsSkeleton(),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _imageSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ShimmerBox(height: 28, width: 170, radius: 8),
        const SizedBox(height: 12),
        const ShimmerBox(height: 260, radius: 14),
        const SizedBox(height: 12),
        Row(
          children: const [
            Expanded(child: ShimmerBox(height: 96, radius: 12)),
            SizedBox(width: 12),
            Expanded(child: ShimmerBox(height: 96, radius: 12)),
            SizedBox(width: 12),
            Expanded(child: ShimmerBox(height: 96, radius: 12)),
          ],
        ),
      ],
    );
  }

  Widget _detailsSkeleton() {
    Widget chips({required int count}) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(
          count,
          (_) => const ShimmerBox(height: 34, width: 92, radius: 100),
        ),
      );
    }

    Widget labelAndField({
      required double labelWidth,
      required double fieldHeight,
    }) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(height: 18, width: labelWidth, radius: 6),
          const SizedBox(height: 8),
          ShimmerBox(height: fieldHeight, radius: 10),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ShimmerBox(height: 24, width: 180, radius: 8),
        const SizedBox(height: 12),
        labelAndField(labelWidth: 110, fieldHeight: 48),
        const SizedBox(height: 12),
        labelAndField(labelWidth: 120, fieldHeight: 94),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: labelAndField(labelWidth: 80, fieldHeight: 48)),
            const SizedBox(width: 10),
            Expanded(child: labelAndField(labelWidth: 130, fieldHeight: 48)),
          ],
        ),
        const SizedBox(height: 12),
        labelAndField(labelWidth: 120, fieldHeight: 48),
        const SizedBox(height: 10),
        chips(count: 7),
        const SizedBox(height: 12),
        labelAndField(labelWidth: 90, fieldHeight: 48),
        const SizedBox(height: 10),
        chips(count: 6),
        const SizedBox(height: 12),
        labelAndField(labelWidth: 85, fieldHeight: 48),
        const SizedBox(height: 12),
        const ShimmerBox(height: 52, radius: 10),
        const SizedBox(height: 16),
        const ShimmerBox(height: 50, radius: 10),
      ],
    );
  }
}
