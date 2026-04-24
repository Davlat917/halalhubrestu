import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_finance_overview/vendor_finance_overview_model.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/widgets/vendor_overview_card.dart';

mixin VendorFinanceOverviewSectionMixin {
  List<VendorOverviewCardData> buildOverviewItems(
    BuildContext context,
    VendorFinanceOverviewModel overview,
  ) {
    return [
      VendorOverviewCardData(
        title: TranslationKeys.vendorDetailDailyEarnings.tr(context: context),
        amount: formatAmount(overview.daily.amount, overview.currency),
        changeText: buildChangeLabel(overview.daily),
        changeColor: statusColor(overview.daily.status),
        status: overview.daily.status,
      ),
      VendorOverviewCardData(
        title: TranslationKeys.vendorDetailWeeklyEarnings.tr(context: context),
        amount: formatAmount(overview.weekly.amount, overview.currency),
        changeText: buildChangeLabel(overview.weekly),
        changeColor: statusColor(overview.weekly.status),
        status: overview.weekly.status,
      ),
      VendorOverviewCardData(
        title: TranslationKeys.vendorDetailMonthlyEarnings.tr(context: context),
        amount: formatAmount(overview.monthly.amount, overview.currency),
        changeText: buildChangeLabel(overview.monthly),
        changeColor: statusColor(overview.monthly.status),
        status: overview.monthly.status,
      ),
      VendorOverviewCardData(
        title: TranslationKeys.vendorDetailYearlyEarnings.tr(context: context),
        amount: formatAmount(overview.yearly.amount, overview.currency),
        changeText: buildChangeLabel(overview.yearly),
        changeColor: statusColor(overview.yearly.status),
        status: overview.yearly.status,
      ),
    ];
  }

  String formatAmount(String amount, String? currency) {
    final trimmed = amount.trim();
    if (trimmed.startsWith('\$')) return trimmed;
    return '\$$trimmed';
  }

  String buildChangeLabel(VendorFinanceMetricModel metric) {
    final baseValue = metric.change.trim();
    if (baseValue.isEmpty || baseValue == '0.00' || baseValue == '0') {
      return '0';
    }

    final cleanValue = baseValue.startsWith('-')
        ? baseValue.substring(1)
        : baseValue;
    switch (metric.status) {
      case 'up':
        return '+$cleanValue';
      case 'down':
        return '-$cleanValue';
      default:
        return cleanValue;
    }
  }

  Color statusColor(String status) {
    switch (status) {
      case 'down':
        return Colors.redAccent;
      case 'same':
        return StaticColors.c9AA0A6;
      default:
        return StaticColors.primary;
    }
  }
}
