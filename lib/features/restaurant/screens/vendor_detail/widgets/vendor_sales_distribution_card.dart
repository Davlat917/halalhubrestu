import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_sales_distribution/vendor_sales_distribution_model.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/bloc/vendor_detail_bloc.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/bloc/vendor_detail_event.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/bloc/vendor_detail_state.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/widgets/vendor_donut_chart.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/widgets/vendor_legend_item.dart';

class VendorSalesDistributionCard extends StatelessWidget {
  const VendorSalesDistributionCard({super.key});

  static const _chartColors = <Color>[
    Color(0xFF2ECC71),
    Color(0xFF67D5B5),
    Color(0xFF5E72E4),
    Color(0xFF74C0E3),
    Color(0xFFC145D1),
    Color(0xFF00ACC1),
    Color(0xFF43A047),
    Color(0xFFF4511E),
    Color(0xFF8E24AA),
    Color(0xFF3949AB),
    Color(0xFFFFB300),
    Color(0xFF00897B),
    Color(0xFFD81B60),
    Color(0xFF6D4C41),
    Color(0xFF7CB342),
    Color(0xFF546E7A),
    Color(0xFF5C6BC0),
    Color(0xFF26A69A),
    Color(0xFFFF7043),
    Color(0xFFAB47BC),
    Color(0xFF9CCC65),
    Color(0xFF42A5F5),
    Color(0xFFFFCA28),
    Color(0xFF26C6DA),
    Color(0xFFEC407A),
    Color(0xFF8D6E63),
    Color(0xFF66BB6A),
    Color(0xFF29B6F6),
    Color(0xFFFF8A65),
    Color(0xFFB39DDB),
  ];

  Color _colorByIndex(int index) => _chartColors[index % _chartColors.length];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: StaticColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: StaticColors.cE2E2E2),
      ),
      child: BlocBuilder<VendorDetailBloc, VendorDetailState>(
        buildWhen: (previous, current) {
          return previous.salesDistributionStatus !=
                  current.salesDistributionStatus ||
              previous.salesDistribution != current.salesDistribution ||
              previous.salesDistributionError != current.salesDistributionError;
        },
        builder: (context, state) {
          return Column(
            children: [
              const SizedBox(height: 8),
              Text(
                TranslationKeys.vendorDetailSalesDistribution.tr(
                  context: context,
                ),
                style: AppTextStyle.regular14(
                  context,
                  color: StaticColors.c9AA0A6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Expanded(child: _buildBody(context, state)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, VendorDetailState state) {
    if (state.salesDistributionStatus == VendorDetailLoadStatus.failure) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            state.salesDistributionError ??
                TranslationKeys.vendorDetailFailedLoadSalesDistribution.tr(
                  context: context,
                ),
            style: AppTextStyle.regular14(context, color: StaticColors.c9AA0A6),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () {
              context.read<VendorDetailBloc>().add(
                const VendorDetailSalesDistributionRequested(),
              );
            },
            child: Text(TranslationKeys.retry.tr(context: context)),
          ),
        ],
      );
    }

    if (state.salesDistributionStatus == VendorDetailLoadStatus.initial ||
        state.salesDistributionStatus == VendorDetailLoadStatus.loading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (state.salesDistribution.isEmpty) {
      return Center(
        child: Text(
          TranslationKeys.vendorDetailNoData.tr(context: context),
          style: AppTextStyle.regular14(context, color: StaticColors.c9AA0A6),
        ),
      );
    }

    final segments = _buildSegments(state.salesDistribution);
    return Row(
      children: [
        Expanded(child: VendorDonutChart(segments: segments)),
        const SizedBox(width: 8),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: state.salesDistribution.length,
            separatorBuilder: (_, _) => const SizedBox(height: 6),
            itemBuilder: (context, index) {
              final item = state.salesDistribution[index];
              final color = _colorByIndex(index);
              return VendorLegendItem(
                '${item.categoryName} (${item.percent}%)',
                color,
              );
            },
          ),
        ),
      ],
    );
  }

  List<(double, Color)> _buildSegments(
    List<VendorSalesDistributionModel> items,
  ) {
    final out = <(double, Color)>[];
    for (var i = 0; i < items.length; i++) {
      out.add((items[i].percentValue, _colorByIndex(i)));
    }
    return out;
  }
}
