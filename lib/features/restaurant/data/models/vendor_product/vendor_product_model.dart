class VendorProductGroupModel {
  VendorProductGroupModel({
    required this.id,
    required this.name,
    this.products = const [],
  });

  final int id;
  final String name;
  final List<VendorProductModel> products;

  factory VendorProductGroupModel.fromJson(Map<String, dynamic> json) {
    return VendorProductGroupModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? '').toString(),
      products: (json['products'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map((e) => VendorProductModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(growable: false),
    );
  }
}

class VendorProductModel {
  VendorProductModel({
    required this.id,
    required this.name,
    this.price,
    this.finalPrice,
    this.description,
    this.preparationTime,
    this.isAvailable,
    this.ingredients = const [],
    this.images = const [],
    this.discounts = const [],
    this.categories = const [],
    this.modifierGroups = const [],
    this.recommendationProducts = const [],
  });

  final int id;
  final String name;
  final String? price;
  final double? finalPrice;
  final String? description;
  final int? preparationTime;
  final bool? isAvailable;
  final List<String> ingredients;
  final List<VendorProductImageModel> images;
  final List<VendorProductDiscountModel> discounts;
  final List<VendorProductCategoryRefModel> categories;
  final List<VendorProductModifierGroupModel> modifierGroups;
  final List<VendorProductRecommendationRefModel> recommendationProducts;

  factory VendorProductModel.fromJson(Map<String, dynamic> json) {
    return VendorProductModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? '').toString(),
      price: json['price']?.toString(),
      finalPrice: (json['final_price'] as num?)?.toDouble(),
      description: json['description']?.toString(),
      preparationTime: (json['preparation_time'] as num?)?.toInt(),
      isAvailable: json['is_available'] as bool?,
      ingredients: (json['ingredients'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(growable: false),
      images: (json['images'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map(
            (e) =>
                VendorProductImageModel.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList(growable: false),
      discounts: (json['discounts'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map(
            (e) => VendorProductDiscountModel.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList(growable: false),
      categories: (json['categories'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map(
            (e) => VendorProductCategoryRefModel.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList(growable: false),
      modifierGroups: _parseModifierGroups(
        json['modifier_groups'] ?? json['modifierGroups'],
      ),
      recommendationProducts: _parseRecommendationProducts(
        json['recommendations'] ??
            json['recommendation_ids'] ??
            json['recommendation_product_ids'] ??
            json['recommendationProducts'] ??
            json['recommended_products'] ??
            json['often_bought_with'] ??
            json['recommendation_products'],
      ),
    );
  }

  static List<VendorProductModifierGroupModel> _parseModifierGroups(
    dynamic value,
  ) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map(
          (e) => VendorProductModifierGroupModel.fromJson(
            Map<String, dynamic>.from(e),
          ),
        )
        .toList(growable: false);
  }

  static List<VendorProductRecommendationRefModel> _parseRecommendationProducts(
    dynamic value,
  ) {
    if (value is! List) return const [];
    return value
        .map((e) {
          if (e is num) {
            return VendorProductRecommendationRefModel(id: e.toInt(), name: '');
          }
          if (e is Map) {
            final source = Map<String, dynamic>.from(e);
            final nested = source['product'];
            final map = nested is Map
                ? Map<String, dynamic>.from(nested)
                : source;
            final id = map['id'] ?? map['product_id'];
            if (id is num) {
              return VendorProductRecommendationRefModel(
                id: id.toInt(),
                name: (map['name'] ?? map['title'] ?? '').toString(),
              );
            }
          }
          final id = int.tryParse(e.toString());
          if (id == null) return null;
          return VendorProductRecommendationRefModel(id: id, name: '');
        })
        .whereType<VendorProductRecommendationRefModel>()
        .where((e) => e.id > 0)
        .toList(growable: false);
  }

  List<int> get recommendationIds =>
      recommendationProducts.map((e) => e.id).toList(growable: false);
}

class VendorProductRecommendationRefModel {
  VendorProductRecommendationRefModel({required this.id, required this.name});

  final int id;
  final String name;
}

class VendorProductModifierGroupModel {
  VendorProductModifierGroupModel({
    required this.name,
    required this.selectionType,
    required this.isRequired,
    required this.minSelect,
    required this.maxSelect,
    this.options = const [],
  });

  final String name;
  final String selectionType;
  final bool isRequired;
  final int minSelect;
  final int maxSelect;
  final List<VendorProductModifierOptionModel> options;

  factory VendorProductModifierGroupModel.fromJson(Map<String, dynamic> json) {
    return VendorProductModifierGroupModel(
      name: (json['name'] ?? '').toString(),
      selectionType: (json['selection_type'] ?? 'single').toString(),
      isRequired: json['is_required'] as bool? ?? false,
      minSelect: (json['min_select'] as num?)?.toInt() ?? 0,
      maxSelect: (json['max_select'] as num?)?.toInt() ?? 1,
      options: (json['options'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map(
            (e) => VendorProductModifierOptionModel.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList(growable: false),
    );
  }
}

class VendorProductModifierOptionModel {
  VendorProductModifierOptionModel({required this.name, required this.price});

  final String name;
  final double price;

  factory VendorProductModifierOptionModel.fromJson(Map<String, dynamic> json) {
    return VendorProductModifierOptionModel(
      name: (json['name'] ?? '').toString(),
      price: (json['price'] as num?)?.toDouble() ?? 0,
    );
  }
}

class VendorProductImageModel {
  VendorProductImageModel({required this.id, required this.imageUrl});

  final int id;
  final String imageUrl;

  factory VendorProductImageModel.fromJson(Map<String, dynamic> json) {
    return VendorProductImageModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      imageUrl: (json['image_url'] ?? '').toString(),
    );
  }
}

class VendorProductDiscountModel {
  VendorProductDiscountModel({required this.id, this.title, this.percent});

  final int id;
  final String? title;
  final double? percent;

  factory VendorProductDiscountModel.fromJson(Map<String, dynamic> json) {
    return VendorProductDiscountModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString(),
      percent: (json['percent'] as num?)?.toDouble(),
    );
  }
}

class VendorProductCategoryRefModel {
  VendorProductCategoryRefModel({required this.id, required this.name});

  final int id;
  final String name;

  factory VendorProductCategoryRefModel.fromJson(Map<String, dynamic> json) {
    return VendorProductCategoryRefModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? '').toString(),
    );
  }
}
