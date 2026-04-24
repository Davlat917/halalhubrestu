import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/bloc/vendor_detail_bloc.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/bloc/vendor_detail_event.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/bloc/vendor_detail_state.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/widgets/vendor_chart_card.dart';

class VendorPerformanceAnalyticsSection extends StatelessWidget {
  const VendorPerformanceAnalyticsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VendorDetailBloc, VendorDetailState>(
      buildWhen: (previous, current) {
        return previous.performanceAnalyticsStatus !=
                current.performanceAnalyticsStatus ||
            previous.performanceAnalytics != current.performanceAnalytics ||
            previous.performanceAnalyticsError !=
                current.performanceAnalyticsError;
      },
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              TranslationKeys.vendorDetailPerformanceAnalytics.tr(
                context: context,
              ),
              style: AppTextStyle.semibold20(
                context,
                color: StaticColors.black,
              ),
            ),
            const SizedBox(height: 12),
            if (state.performanceAnalyticsStatus ==
                VendorDetailLoadStatus.failure)
              Container(
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
                      state.performanceAnalyticsError ??
                          TranslationKeys
                              .vendorDetailFailedLoadPerformanceAnalytics
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
                          const VendorDetailPerformanceAnalyticsRequested(),
                        );
                      },
                      child: Text(TranslationKeys.retry.tr(context: context)),
                    ),
                  ],
                ),
              )
            else
              VendorChartCard(
                points: state.performanceAnalytics.points,
                isLoading:
                    state.performanceAnalyticsStatus ==
                        VendorDetailLoadStatus.initial ||
                    state.performanceAnalyticsStatus ==
                        VendorDetailLoadStatus.loading,
              ),
          ],
        );
      },
    );
  }
}
