import 'package:equatable/equatable.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_finance_overview/vendor_finance_overview_model.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_finance_performance/vendor_finance_performance_model.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_sales_distribution/vendor_sales_distribution_model.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_top_customer/vendor_top_customer_model.dart';

enum VendorDetailLoadStatus { initial, loading, success, failure }

final class VendorDetailState extends Equatable {
  const VendorDetailState({
    this.financeOverviewStatus = VendorDetailLoadStatus.initial,
    this.financeOverview = const VendorFinanceOverviewModel.empty(),
    this.financeOverviewError,
    this.performanceAnalyticsStatus = VendorDetailLoadStatus.initial,
    this.performanceAnalytics = const VendorFinancePerformanceModel.empty(),
    this.performanceAnalyticsError,
    this.topCustomersStatus = VendorDetailLoadStatus.initial,
    this.topCustomers = const [],
    this.topCustomersError,
    this.salesDistributionStatus = VendorDetailLoadStatus.initial,
    this.salesDistribution = const [],
    this.salesDistributionError,
  });

  final VendorDetailLoadStatus financeOverviewStatus;
  final VendorFinanceOverviewModel financeOverview;
  final String? financeOverviewError;

  final VendorDetailLoadStatus performanceAnalyticsStatus;
  final VendorFinancePerformanceModel performanceAnalytics;
  final String? performanceAnalyticsError;

  final VendorDetailLoadStatus topCustomersStatus;
  final List<VendorTopCustomerModel> topCustomers;
  final String? topCustomersError;

  final VendorDetailLoadStatus salesDistributionStatus;
  final List<VendorSalesDistributionModel> salesDistribution;
  final String? salesDistributionError;

  VendorDetailState copyWith({
    VendorDetailLoadStatus? financeOverviewStatus,
    VendorFinanceOverviewModel? financeOverview,
    String? financeOverviewError,
    bool clearFinanceOverviewError = false,
    VendorDetailLoadStatus? performanceAnalyticsStatus,
    VendorFinancePerformanceModel? performanceAnalytics,
    String? performanceAnalyticsError,
    bool clearPerformanceAnalyticsError = false,
    VendorDetailLoadStatus? topCustomersStatus,
    List<VendorTopCustomerModel>? topCustomers,
    String? topCustomersError,
    bool clearTopCustomersError = false,
    VendorDetailLoadStatus? salesDistributionStatus,
    List<VendorSalesDistributionModel>? salesDistribution,
    String? salesDistributionError,
    bool clearSalesDistributionError = false,
  }) {
    return VendorDetailState(
      financeOverviewStatus:
          financeOverviewStatus ?? this.financeOverviewStatus,
      financeOverview: financeOverview ?? this.financeOverview,
      financeOverviewError: clearFinanceOverviewError
          ? null
          : (financeOverviewError ?? this.financeOverviewError),
      performanceAnalyticsStatus:
          performanceAnalyticsStatus ?? this.performanceAnalyticsStatus,
      performanceAnalytics:
          performanceAnalytics ?? this.performanceAnalytics,
      performanceAnalyticsError: clearPerformanceAnalyticsError
          ? null
          : (performanceAnalyticsError ?? this.performanceAnalyticsError),
      topCustomersStatus: topCustomersStatus ?? this.topCustomersStatus,
      topCustomers: topCustomers ?? this.topCustomers,
      topCustomersError: clearTopCustomersError
          ? null
          : (topCustomersError ?? this.topCustomersError),
      salesDistributionStatus:
          salesDistributionStatus ?? this.salesDistributionStatus,
      salesDistribution: salesDistribution ?? this.salesDistribution,
      salesDistributionError: clearSalesDistributionError
          ? null
          : (salesDistributionError ?? this.salesDistributionError),
    );
  }

  @override
  List<Object?> get props => [
        financeOverviewStatus,
        financeOverview,
        financeOverviewError,
        performanceAnalyticsStatus,
        performanceAnalytics,
        performanceAnalyticsError,
        topCustomersStatus,
        topCustomers,
        topCustomersError,
        salesDistributionStatus,
        salesDistribution,
        salesDistributionError,
      ];
}
