import 'package:equatable/equatable.dart';

class VendorFinancePerformancePointModel extends Equatable {
  const VendorFinancePerformancePointModel({
    required this.day,
    required this.date,
    required this.revenue,
    required this.ordersCount,
  });

  final int day;
  final String date;
  final String revenue;
  final int ordersCount;

  double get revenueValue => double.tryParse(revenue) ?? 0;

  factory VendorFinancePerformancePointModel.fromJson(Map<String, dynamic> json) {
    return VendorFinancePerformancePointModel(
      day: json['day'] as int? ?? 0,
      date: json['date'] as String? ?? '',
      revenue: json['revenue'] as String? ?? '0.00',
      ordersCount: json['orders_count'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [day, date, revenue, ordersCount];
}

class VendorFinancePerformanceModel extends Equatable {
  const VendorFinancePerformanceModel({
    required this.points,
    required this.total,
  });

  final List<VendorFinancePerformancePointModel> points;
  final String total;

  factory VendorFinancePerformanceModel.fromJson(Map<String, dynamic> json) {
    final rawPoints = json['points'];
    final points = <VendorFinancePerformancePointModel>[];
    if (rawPoints is List) {
      for (final row in rawPoints) {
        if (row is Map) {
          points.add(
            VendorFinancePerformancePointModel.fromJson(
              Map<String, dynamic>.from(row),
            ),
          );
        }
      }
    }
    return VendorFinancePerformanceModel(
      points: points,
      total: json['total'] as String? ?? '0.00',
    );
  }

  const VendorFinancePerformanceModel.empty()
      : points = const [],
        total = '0.00';

  @override
  List<Object?> get props => [points, total];
}
