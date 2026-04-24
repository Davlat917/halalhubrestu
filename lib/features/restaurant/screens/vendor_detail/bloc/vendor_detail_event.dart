import 'package:equatable/equatable.dart';

sealed class VendorDetailEvent extends Equatable {
  const VendorDetailEvent();

  @override
  List<Object?> get props => [];
}

final class VendorDetailInitialized extends VendorDetailEvent {
  const VendorDetailInitialized();
}

final class VendorDetailFinanceOverviewRequested extends VendorDetailEvent {
  const VendorDetailFinanceOverviewRequested();
}

final class VendorDetailPerformanceAnalyticsRequested extends VendorDetailEvent {
  const VendorDetailPerformanceAnalyticsRequested();
}

final class VendorDetailTopCustomersRequested extends VendorDetailEvent {
  const VendorDetailTopCustomersRequested();
}

final class VendorDetailSalesDistributionRequested extends VendorDetailEvent {
  const VendorDetailSalesDistributionRequested();
}
