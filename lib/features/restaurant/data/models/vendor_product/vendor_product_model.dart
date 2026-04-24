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
          .map((e) => VendorProductImageModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(growable: false),
      discounts: (json['discounts'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map((e) => VendorProductDiscountModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(growable: false),
      categories: (json['categories'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map((e) => VendorProductCategoryRefModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(growable: false),
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
  VendorProductDiscountModel({
    required this.id,
    this.title,
    this.percent,
  });

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
  VendorProductCategoryRefModel({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;

  factory VendorProductCategoryRefModel.fromJson(Map<String, dynamic> json) {
    return VendorProductCategoryRefModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? '').toString(),
    );
  }
}
