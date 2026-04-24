import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/bloc/vendor_detail_bloc.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/bloc/vendor_detail_event.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/bloc/vendor_detail_state.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/mixins/vendor_finance_overview_section_mixin.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/widgets/vendor_overview_grid.dart';

class VendorFinanceOverviewSection extends StatelessWidget {
  const VendorFinanceOverviewSection({
    super.key,
    required this.isWide,
    required this.crossAxisCount,
  });

  final bool isWide;
  final int crossAxisCount;

  @override
  Widget build(BuildContext context) {
    return _VendorFinanceOverviewSectionView(
      isWide: isWide,
      crossAxisCount: crossAxisCount,
    );
  }
}

class _VendorFinanceOverviewSectionView extends StatelessWidget
    with VendorFinanceOverviewSectionMixin {
  const _VendorFinanceOverviewSectionView({
    required this.isWide,
    required this.crossAxisCount,
  });

  final bool isWide;
  final int crossAxisCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          TranslationKeys.vendorDetailFinancialOverview.tr(context: context),
          style: AppTextStyle.semibold20(context, color: StaticColors.black),
        ),
        const SizedBox(height: 12),
        BlocBuilder<VendorDetailBloc, VendorDetailState>(
          buildWhen: (previous, current) {
            return previous.financeOverviewStatus !=
                    current.financeOverviewStatus ||
                previous.financeOverview != current.financeOverview ||
                previous.financeOverviewError != current.financeOverviewError;
          },
          builder: (context, state) {
            if (state.financeOverviewStatus == VendorDetailLoadStatus.failure) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: StaticColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: StaticColors.cE2E2E2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.financeOverviewError ??
                          TranslationKeys.vendorDetailFailedLoadFinanceOverview
                              .tr(context: context),
                      style: AppTextStyle.regular14(
                        context,
                        color: StaticColors.c9AA0A6,
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () {
                        context.read<VendorDetailBloc>().add(
                          const VendorDetailFinanceOverviewRequested(),
                        );
                      },
                      child: Text(TranslationKeys.retry.tr(context: context)),
                    ),
                  ],
                ),
              );
            }

            return VendorOverviewGrid(
              crossAxisCount: crossAxisCount,
              isWide: isWide,
              items: buildOverviewItems(context, state.financeOverview),
              isLoading:
                  state.financeOverviewStatus ==
                      VendorDetailLoadStatus.initial ||
                  state.financeOverviewStatus == VendorDetailLoadStatus.loading,
            );
          },
        ),
      ],
    );
  }
}
