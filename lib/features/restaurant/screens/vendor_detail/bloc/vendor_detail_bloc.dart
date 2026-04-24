import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/network/network_exception.dart';
import 'package:halalhub_restaurant/features/restaurant/data/repositories/restaurant_repo.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/bloc/vendor_detail_event.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/bloc/vendor_detail_state.dart';

class VendorDetailBloc extends Bloc<VendorDetailEvent, VendorDetailState> {
  VendorDetailBloc(this._repo) : super(const VendorDetailState()) {
    on<VendorDetailInitialized>(_onInitialized);
    on<VendorDetailFinanceOverviewRequested>(_onFinanceOverviewRequested);
    on<VendorDetailPerformanceAnalyticsRequested>(
      _onPerformanceAnalyticsRequested,
    );
    on<VendorDetailTopCustomersRequested>(_onTopCustomersRequested);
    on<VendorDetailSalesDistributionRequested>(_onSalesDistributionRequested);
  }

  final RestaurantRepo _repo;

  Future<void> _onInitialized(
    VendorDetailInitialized event,
    Emitter<VendorDetailState> emit,
  ) async {
    add(const VendorDetailFinanceOverviewRequested());
    add(const VendorDetailPerformanceAnalyticsRequested());
    add(const VendorDetailTopCustomersRequested());
    add(const VendorDetailSalesDistributionRequested());
  }

  Future<void> _onFinanceOverviewRequested(
    VendorDetailFinanceOverviewRequested event,
    Emitter<VendorDetailState> emit,
  ) async {
    emit(
      state.copyWith(
        financeOverviewStatus: VendorDetailLoadStatus.loading,
        clearFinanceOverviewError: true,
      ),
    );
    try {
      final overview = await _repo.getVendorFinanceOverview();
      emit(
        state.copyWith(
          financeOverviewStatus: VendorDetailLoadStatus.success,
          financeOverview: overview,
          clearFinanceOverviewError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          financeOverviewStatus: VendorDetailLoadStatus.failure,
          financeOverviewError: e.toString(),
        ),
      );
    }
  }

  Future<void> _onPerformanceAnalyticsRequested(
    VendorDetailPerformanceAnalyticsRequested event,
    Emitter<VendorDetailState> emit,
  ) async {
    emit(
      state.copyWith(
        performanceAnalyticsStatus: VendorDetailLoadStatus.loading,
        clearPerformanceAnalyticsError: true,
      ),
    );
    try {
      final performance = await _repo.getVendorFinancePerformance();
      emit(
        state.copyWith(
          performanceAnalyticsStatus: VendorDetailLoadStatus.success,
          performanceAnalytics: performance,
          clearPerformanceAnalyticsError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          performanceAnalyticsStatus: VendorDetailLoadStatus.failure,
          performanceAnalyticsError: e.toString(),
        ),
      );
    }
  }

  Future<void> _onTopCustomersRequested(
    VendorDetailTopCustomersRequested event,
    Emitter<VendorDetailState> emit,
  ) async {
    emit(
      state.copyWith(
        topCustomersStatus: VendorDetailLoadStatus.loading,
        clearTopCustomersError: true,
      ),
    );
    try {
      final customers = await _repo.getVendorFinanceTopCustomers();
      emit(
        state.copyWith(
          topCustomersStatus: VendorDetailLoadStatus.success,
          topCustomers: customers,
          clearTopCustomersError: true,
        ),
      );
    } catch (e) {
      final networkError = e is NetworkException ? e : null;
      emit(
        state.copyWith(
          topCustomersStatus: VendorDetailLoadStatus.failure,
          topCustomersError:
              networkError?.message ??
              TranslationKeys.vendorDetailFailedLoadCustomers.tr(),
        ),
      );
    }
  }

  Future<void> _onSalesDistributionRequested(
    VendorDetailSalesDistributionRequested event,
    Emitter<VendorDetailState> emit,
  ) async {
    emit(
      state.copyWith(
        salesDistributionStatus: VendorDetailLoadStatus.loading,
        clearSalesDistributionError: true,
      ),
    );
    try {
      final distribution = await _repo.getVendorFinanceSalesDistribution();
      emit(
        state.copyWith(
          salesDistributionStatus: VendorDetailLoadStatus.success,
          salesDistribution: distribution,
          clearSalesDistributionError: true,
        ),
      );
    } catch (e) {
      final networkError = e is NetworkException ? e : null;
      emit(
        state.copyWith(
          salesDistributionStatus: VendorDetailLoadStatus.failure,
          salesDistributionError:
              networkError?.message ??
              TranslationKeys.vendorDetailFailedLoadSalesDistribution.tr(),
        ),
      );
    }
  }
}
