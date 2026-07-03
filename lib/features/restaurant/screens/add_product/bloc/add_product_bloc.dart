import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_category/vendor_category_model.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_ingredient/vendor_ingredient_model.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_product/vendor_product_model.dart';
import 'package:halalhub_restaurant/features/restaurant/data/repositories/restaurant_repo.dart';
import 'package:image_picker/image_picker.dart';

class AddProductModifierOption {
  const AddProductModifierOption({required this.name, required this.price});

  final String name;
  final double price;

  Map<String, dynamic> toJson() => {'name': name, 'price': price};
}

class AddProductModifierGroup {
  const AddProductModifierGroup({
    required this.name,
    required this.selectionType,
    required this.isRequired,
    required this.minSelect,
    required this.maxSelect,
    required this.options,
  });

  final String name;
  final String selectionType;
  final bool isRequired;
  final int minSelect;
  final int maxSelect;
  final List<AddProductModifierOption> options;

  Map<String, dynamic> toJson() => {
    'name': name,
    'selection_type': selectionType,
    'is_required': isRequired,
    'min_select': minSelect,
    'max_select': maxSelect,
    'options': options.map((e) => e.toJson()).toList(growable: false),
  };
}

class AddProductState {
  const AddProductState({
    this.categories = const [],
    this.ingredients = const [],
    this.recommendationProducts = const [],
    this.selectedCategoryIds = const <int>{},
    this.selectedIngredientIds = const <int>{},
    this.selectedRecommendationIds = const <int>{},
    this.modifierGroups = const [],
    this.images = const [],
    this.isAvailable = true,
    this.isLoadingCategories = false,
    this.isLoadingIngredients = false,
    this.isSubmitting = false,
    this.categoriesReady = false,
    this.ingredientsReady = false,
    this.errorMessage,
    this.success = false,
  });

  final List<VendorCategoryModel> categories;
  final List<VendorIngredientModel> ingredients;
  final List<VendorProductModel> recommendationProducts;
  final Set<int> selectedCategoryIds;
  final Set<int> selectedIngredientIds;
  final Set<int> selectedRecommendationIds;
  final List<AddProductModifierGroup> modifierGroups;
  final List<XFile> images;
  final bool isAvailable;
  final bool isLoadingCategories;
  final bool isLoadingIngredients;
  final bool isSubmitting;
  final bool categoriesReady;
  final bool ingredientsReady;
  final String? errorMessage;
  final bool success;

  AddProductState copyWith({
    List<VendorCategoryModel>? categories,
    List<VendorIngredientModel>? ingredients,
    List<VendorProductModel>? recommendationProducts,
    Set<int>? selectedCategoryIds,
    Set<int>? selectedIngredientIds,
    Set<int>? selectedRecommendationIds,
    List<AddProductModifierGroup>? modifierGroups,
    List<XFile>? images,
    bool? isAvailable,
    bool? isLoadingCategories,
    bool? isLoadingIngredients,
    bool? isSubmitting,
    bool? categoriesReady,
    bool? ingredientsReady,
    String? errorMessage,
    bool clearError = false,
    bool? success,
  }) {
    return AddProductState(
      categories: categories ?? this.categories,
      ingredients: ingredients ?? this.ingredients,
      recommendationProducts:
          recommendationProducts ?? this.recommendationProducts,
      selectedCategoryIds: selectedCategoryIds ?? this.selectedCategoryIds,
      selectedIngredientIds:
          selectedIngredientIds ?? this.selectedIngredientIds,
      selectedRecommendationIds:
          selectedRecommendationIds ?? this.selectedRecommendationIds,
      modifierGroups: modifierGroups ?? this.modifierGroups,
      images: images ?? this.images,
      isAvailable: isAvailable ?? this.isAvailable,
      isLoadingCategories: isLoadingCategories ?? this.isLoadingCategories,
      isLoadingIngredients: isLoadingIngredients ?? this.isLoadingIngredients,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      categoriesReady: categoriesReady ?? this.categoriesReady,
      ingredientsReady: ingredientsReady ?? this.ingredientsReady,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      success: success ?? this.success,
    );
  }
}

class AddProductBloc extends Cubit<AddProductState> {
  AddProductBloc(this._repo) : super(const AddProductState());

  final RestaurantRepo _repo;
  static const int maxImages = 3;

  Future<void> loadInitialData() async {
    emit(
      state.copyWith(
        isLoadingCategories: true,
        isLoadingIngredients: true,
        categoriesReady: false,
        ingredientsReady: false,
        clearError: true,
        success: false,
      ),
    );
    try {
      final results = await Future.wait([
        _repo.getVendorProductCategories(),
        _repo.getVendorIngredients(),
        _loadRecommendationProducts(),
      ]);
      final categories = results[0] as List<VendorCategoryModel>;
      final ingredients = results[1] as List<VendorIngredientModel>;
      final recommendationProducts = results[2] as List<VendorProductModel>;
      emit(
        state.copyWith(
          categories: categories,
          ingredients: ingredients,
          recommendationProducts: recommendationProducts,
          isLoadingCategories: false,
          isLoadingIngredients: false,
          categoriesReady: true,
          ingredientsReady: true,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoadingCategories: false,
          isLoadingIngredients: false,
          categoriesReady: false,
          ingredientsReady: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void setAvailability(bool value) {
    emit(state.copyWith(isAvailable: value, success: false));
  }

  void toggleCategory(int id, bool selected) {
    final updated = <int>{};
    if (selected) updated.add(id);
    emit(state.copyWith(selectedCategoryIds: updated, success: false));
  }

  void toggleIngredient(int id, bool selected) {
    final updated = {...state.selectedIngredientIds};
    if (selected) {
      updated.add(id);
    } else {
      updated.remove(id);
    }
    emit(state.copyWith(selectedIngredientIds: updated, success: false));
  }

  Future<List<VendorProductModel>> _loadRecommendationProducts() async {
    try {
      final vendor = await _repo.getVendorMe();
      final vendorId = vendor.id;
      if (vendorId == null) return const [];
      final groups = await _repo.getVendorProductsByVendorId(vendorId);
      return groups
          .expand((group) => group.products)
          .where((product) => product.id > 0)
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  void toggleRecommendation(int id, bool selected) {
    final updated = {...state.selectedRecommendationIds};
    if (selected) {
      updated.add(id);
    } else {
      updated.remove(id);
    }
    emit(state.copyWith(selectedRecommendationIds: updated, success: false));
  }

  void addModifierGroup(AddProductModifierGroup group) {
    emit(
      state.copyWith(
        modifierGroups: [...state.modifierGroups, group],
        success: false,
      ),
    );
  }

  void updateModifierGroupAt(int index, AddProductModifierGroup group) {
    if (index < 0 || index >= state.modifierGroups.length) return;
    final updated = [...state.modifierGroups]..[index] = group;
    emit(state.copyWith(modifierGroups: updated, success: false));
  }

  void removeModifierGroupAt(int index) {
    if (index < 0 || index >= state.modifierGroups.length) return;
    final updated = [...state.modifierGroups]..removeAt(index);
    emit(state.copyWith(modifierGroups: updated, success: false));
  }

  void addImages(List<XFile> files) {
    if (files.isEmpty) return;
    final merged = [...state.images, ...files];
    final limited = merged.take(maxImages).toList(growable: false);
    emit(state.copyWith(images: limited, success: false));
  }

  void removeImageAt(int index) {
    if (index < 0 || index >= state.images.length) return;
    final updated = [...state.images]..removeAt(index);
    emit(state.copyWith(images: updated, success: false));
  }

  void clearFormState() {
    emit(
      state.copyWith(
        selectedCategoryIds: <int>{},
        selectedIngredientIds: <int>{},
        selectedRecommendationIds: <int>{},
        modifierGroups: const [],
        images: const [],
        isAvailable: true,
        clearError: true,
        success: false,
      ),
    );
  }

  void hydrateForEdit({
    required Set<int> selectedCategoryIds,
    required Set<int> selectedIngredientIds,
    required bool isAvailable,
    Set<int> selectedRecommendationIds = const <int>{},
    List<VendorProductModel> initialRecommendationProducts = const [],
    List<AddProductModifierGroup> modifierGroups = const [],
  }) {
    final recommendationProducts = [...state.recommendationProducts];
    for (final product in initialRecommendationProducts) {
      final exists = recommendationProducts.any(
        (item) => item.id == product.id,
      );
      if (!exists) recommendationProducts.add(product);
    }
    emit(
      state.copyWith(
        selectedCategoryIds: selectedCategoryIds,
        selectedIngredientIds: selectedIngredientIds,
        selectedRecommendationIds: selectedRecommendationIds,
        recommendationProducts: recommendationProducts,
        modifierGroups: modifierGroups,
        isAvailable: isAvailable,
        success: false,
      ),
    );
  }

  Future<void> submit({
    required String name,
    required int preparationTime,
    double? price,
    String? description,
    String? discountsJson,
    String? deletedImageIds,
    String? modifierGroupsJson,
    String? recommendationsJson,
  }) async {
    emit(state.copyWith(isSubmitting: true, clearError: true, success: false));
    try {
      final selectedIngredients = state.ingredients
          .where((e) => state.selectedIngredientIds.contains(e.id))
          .map((e) => e.title)
          .toList(growable: false);
      await _repo.createVendorProduct(
        name: name,
        preparationTime: preparationTime,
        price: price,
        description: description,
        isAvailable: state.isAvailable,
        categories: state.selectedCategoryIds.toList(),
        newIngredients: selectedIngredients,
        discountsJson: discountsJson,
        deletedImageIds: deletedImageIds,
        modifierGroupsJson: modifierGroupsJson,
        recommendationsJson: recommendationsJson,
        newImages: state.images,
      );
      emit(
        state.copyWith(isSubmitting: false, clearError: true, success: true),
      );
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: e.toString()));
    }
  }

  Future<void> submitEdit({
    required int vendorId,
    required int productId,
    required String name,
    required int preparationTime,
    double? price,
    String? description,
    String? discountsJson,
    String? deletedImageIds,
    String? modifierGroupsJson,
    String? recommendationsJson,
  }) async {
    emit(state.copyWith(isSubmitting: true, clearError: true, success: false));
    try {
      final selectedIngredients = state.ingredients
          .where((e) => state.selectedIngredientIds.contains(e.id))
          .map((e) => e.title)
          .toList(growable: false);
      await _repo.updateVendorProduct(
        vendorId: vendorId,
        productId: productId,
        name: name,
        preparationTime: preparationTime,
        price: price,
        description: description,
        isAvailable: state.isAvailable,
        categories: state.selectedCategoryIds.toList(),
        newIngredients: selectedIngredients,
        discountsJson: discountsJson,
        deletedImageIds: deletedImageIds,
        modifierGroupsJson: modifierGroupsJson,
        recommendationsJson: recommendationsJson,
        newImages: state.images,
      );
      emit(
        state.copyWith(isSubmitting: false, clearError: true, success: true),
      );
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: e.toString()));
    }
  }
}
