import 'package:equatable/equatable.dart';

/// GET `/vendors/vendor/finance/sales-distribution/`
class VendorSalesDistributionModel extends Equatable {
  const VendorSalesDistributionModel({
    required this.categoryId,
    required this.categoryName,
    required this.revenue,
    required this.percent,
  });

  final int categoryId;
  final String categoryName;
  final String revenue;
  final String percent;

  double get percentValue => double.tryParse(percent) ?? 0;

  factory VendorSalesDistributionModel.fromJson(Map<String, dynamic> json) {
    return VendorSalesDistributionModel(
      categoryId: json['category_id'] as int? ?? 0,
      categoryName: json['category_name'] as String? ?? '',
      revenue: json['revenue']?.toString() ?? '0.00',
      percent: json['percent']?.toString() ?? '0.00',
    );
  }

  @override
  List<Object?> get props => [categoryId, categoryName, revenue, percent];
}
