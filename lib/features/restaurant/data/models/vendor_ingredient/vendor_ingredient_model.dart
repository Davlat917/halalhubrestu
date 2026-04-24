class VendorIngredientModel {
  VendorIngredientModel({
    required this.id,
    required this.title,
  });

  final int id;
  final String title;

  factory VendorIngredientModel.fromJson(Map<String, dynamic> json) {
    return VendorIngredientModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: (json['title'] ?? '').toString(),
    );
  }
}
