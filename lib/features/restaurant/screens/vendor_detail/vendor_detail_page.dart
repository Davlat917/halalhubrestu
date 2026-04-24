import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:halalhub_restaurant/core/di/injection.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/core/widgets/shimmer_item.dart';
import 'package:halalhub_restaurant/features/restaurant/data/repositories/restaurant_repo.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/bloc/vendor_detail_bloc.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/bloc/vendor_detail_event.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/bloc/vendor_detail_state.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/mixins/vendor_detail_page_mixin.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/sections/vendor_finance_overview_section.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/sections/vendor_performance_analytics_section.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/sections/vendor_sales_and_customers_section.dart';
import 'package:shimmer/shimmer.dart';

class VendorDetailPage extends StatefulWidget {
  const VendorDetailPage({super.key, this.bloc});

  final VendorDetailBloc? bloc;

  @override
  State<VendorDetailPage> createState() => _VendorDetailPageState();
}

class _VendorDetailPageState extends State<VendorDetailPage>
    with VendorDetailPageMixin {
  Future<void> _onRefresh(BuildContext context) async {
    final bloc = context.read<VendorDetailBloc>();
    bloc.add(const VendorDetailFinanceOverviewRequested());
    bloc.add(const VendorDetailPerformanceAnalyticsRequested());
    bloc.add(const VendorDetailTopCustomersRequested());
    bloc.add(const VendorDetailSalesDistributionRequested());
    await Future<void>.delayed(const Duration(milliseconds: 700));
  }

  @override
  Widget build(BuildContext context) {
    final providedBloc = widget.bloc;
    if (providedBloc != null) {
      return BlocProvider.value(
        value: providedBloc,
        child: _buildContent(),
      );
    }
    return BlocProvider(
      create: (_) =>
          VendorDetailBloc(getIt<RestaurantRepo>())..add(const VendorDetailInitialized()),
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    return ColoredBox(
        color: StaticColors.cF8F8F8,
        child: SafeArea(
          top: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = isWideLayout(constraints);
              final hPad = horizontalPadding(isWide);
              final cardsPerRow = financeCardsPerRow(isWide);
              return RefreshIndicator(
                onRefresh: () => _onRefresh(context),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(hPad, 14, hPad, 20),
                  child: BlocBuilder<VendorDetailBloc, VendorDetailState>(
                    buildWhen: (previous, current) =>
                        previous.financeOverviewStatus !=
                            current.financeOverviewStatus ||
                        previous.performanceAnalyticsStatus !=
                            current.performanceAnalyticsStatus ||
                        previous.topCustomersStatus != current.topCustomersStatus ||
                        previous.salesDistributionStatus !=
                            current.salesDistributionStatus,
                    builder: (context, state) {
                      if (_showDetailLoadingSkeleton(state)) {
                        return _VendorDetailLoadingSkeleton(isWide: isWide);
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          VendorFinanceOverviewSection(
                            isWide: isWide,
                            crossAxisCount: cardsPerRow,
                          ),
                          const SizedBox(height: 14),
                          const VendorPerformanceAnalyticsSection(),
                          const SizedBox(height: 14),
                          VendorSalesAndCustomersSection(isWide: isWide),
                        ],
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      );
  }

  bool _showDetailLoadingSkeleton(VendorDetailState state) {
    bool waiting(VendorDetailLoadStatus status) =>
        status == VendorDetailLoadStatus.initial ||
        status == VendorDetailLoadStatus.loading;
    return waiting(state.financeOverviewStatus) &&
        waiting(state.performanceAnalyticsStatus) &&
        waiting(state.topCustomersStatus) &&
        waiting(state.salesDistributionStatus);
  }
}

class _VendorDetailLoadingSkeleton extends StatelessWidget {
  const _VendorDetailLoadingSkeleton({required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: StaticColors.cE2E2E2,
      highlightColor: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 96,
            child: GridView.builder(
              itemCount: isWide ? 4 : 2,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isWide ? 4 : 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: isWide ? 2.2 : 2.5,
              ),
              itemBuilder: (_, _) => const ShimmerBox(height: 40, radius: 12),
            ),
          ),
          const SizedBox(height: 14),
          const ShimmerBox(height: 220, radius: 12),
          const SizedBox(height: 14),
          if (isWide)
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: ShimmerBox(height: 260, radius: 12)),
                SizedBox(width: 12),
                Expanded(child: ShimmerBox(height: 260, radius: 12)),
              ],
            )
          else
            const Column(
              children: [
                ShimmerBox(height: 240, radius: 12),
                SizedBox(height: 12),
                ShimmerBox(height: 240, radius: 12),
              ],
            ),
        ],
      ),
    );
  }
}
