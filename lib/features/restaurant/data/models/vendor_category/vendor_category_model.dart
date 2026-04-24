class VendorCategoryModel {
  VendorCategoryModel({required this.id, required this.name, this.iconUrl});

  final int id;
  final String name;
  final String? iconUrl;

  factory VendorCategoryModel.fromJson(Map<String, dynamic> json) {
    return VendorCategoryModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? '').toString(),
      iconUrl: json['icon_url']?.toString(),
    );
  }
}
