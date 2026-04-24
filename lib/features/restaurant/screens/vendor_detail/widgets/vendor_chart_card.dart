import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_finance_performance/vendor_finance_performance_model.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/widgets/vendor_area_chart_painter_widget.dart';

/// Y o‘qi doim 0 … 250 (buyurtmalar soni bo‘yicha chiziq shu masshtabda).
const double kVendorChartYMaxOrders = 250;

/// Kunlar orasida minimal masofa — 30 kun siqilmasligi uchun grafik kengligi scroll bilan o‘sadi.
const double _kMinWidthPerGapBetweenDays = 14;

class VendorChartCard extends StatefulWidget {
  const VendorChartCard({
    super.key,
    required this.points,
    required this.isLoading,
  });

  final List<VendorFinancePerformancePointModel> points;
  final bool isLoading;

  @override
  State<VendorChartCard> createState() => _VendorChartCardState();
}

class _VendorChartCardState extends State<VendorChartCard> {
  String? _selectedMonth;
  String? _selectedYear;
  int? _selectedPointIndex;

  @override
  void initState() {
    super.initState();
    _syncSelectedValues();
  }

  @override
  void didUpdateWidget(covariant VendorChartCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.points != widget.points) {
      _syncSelectedValues();
    }
  }

  void _syncSelectedValues() {
    final monthItems = _monthItems(widget.points);
    final yearItems = _yearItems(widget.points);
    _selectedMonth = monthItems.contains(_selectedMonth)
        ? _selectedMonth
        : (monthItems.isEmpty ? null : monthItems.first);
    _selectedYear = yearItems.contains(_selectedYear)
        ? _selectedYear
        : (yearItems.isEmpty ? null : yearItems.first);
    _selectedPointIndex = _defaultSelectedPointIndex(widget.points);
  }

  int? _defaultSelectedPointIndex(
    List<VendorFinancePerformancePointModel> points,
  ) {
    if (points.isEmpty) return null;
    final now = DateTime.now();
    for (var i = 0; i < points.length; i++) {
      final parsed = DateTime.tryParse(points[i].date);
      if (parsed != null &&
          parsed.year == now.year &&
          parsed.month == now.month &&
          parsed.day == now.day) {
        return i;
      }
    }
    return points.length - 1;
  }

  @override
  Widget build(BuildContext context) {
    final monthItems = _monthItems(widget.points);
    final yearItems = _yearItems(widget.points);

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
      decoration: BoxDecoration(
        color: StaticColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: StaticColors.cE2E2E2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    TranslationKeys.vendorDetailDailyOrdersChart.tr(
                      context: context,
                    ),
                    textAlign: TextAlign.center,
                    style: AppTextStyle.regular12(
                      context,
                      color: StaticColors.c9AA0A6,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (_selectedMonth != null)
                _ChartDropdown<String>(
                  value: _selectedMonth!,
                  items: monthItems,
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _selectedMonth = value);
                  },
                ),
              const SizedBox(width: 8),
              if (_selectedYear != null)
                _ChartDropdown<String>(
                  value: _selectedYear!,
                  items: yearItems,
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _selectedYear = value);
                  },
                ),
            ],
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              final yTicks = _fixedYAxisLabels250TopToBottom();
              final viewportW = constraints.maxWidth;
              final yW = _measureYAxisLabelsWidth(context, yTicks);
              const gap = 8.0;
              const minChartW = 200.0;
              final rawChartW = viewportW - yW - gap;
              final n = widget.points.length;
              final minWidthForDays = n > 1
                  ? (n - 1) * _kMinWidthPerGapBetweenDays
                  : 0.0;
              final chartW = math.max(
                math.max(rawChartW, minChartW),
                minWidthForDays,
              );

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: yW + gap + chartW,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ChartYAxis(labels: yTicks, width: yW),
                      SizedBox(width: gap),
                      SizedBox(
                        width: chartW,
                        height: 320,
                        child: VendorAreaChartPainterWidget(
                          points: widget.points,
                          maxYValue: kVendorChartYMaxOrders,
                          isLoading: widget.isLoading,
                          selectedIndex: _selectedPointIndex,
                          onSelectIndex: (index) {
                            setState(() => _selectedPointIndex = index);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  List<String> _monthItems(List<VendorFinancePerformancePointModel> points) {
    final items = <String>[];
    for (final point in points) {
      final label = _monthLabel(point.date);
      if (label != null && !items.contains(label)) {
        items.add(label);
      }
    }
    return items;
  }

  List<String> _yearItems(List<VendorFinancePerformancePointModel> points) {
    final items = <String>[];
    for (final point in points) {
      final label = _yearLabel(point.date);
      if (label != null && !items.contains(label)) {
        items.add(label);
      }
    }
    return items;
  }

  String? _monthLabel(String date) {
    final parsed = DateTime.tryParse(date);
    if (parsed == null) return null;
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    if (parsed.month < 1 || parsed.month > 12) return null;
    return 'month.${months[parsed.month]}'.tr();
  }

  String? _yearLabel(String date) {
    final parsed = DateTime.tryParse(date);
    if (parsed == null) return null;
    return TranslationKeys.vendorDetailYearLabel.tr(
      namedArgs: {'year': '${parsed.year}'},
    );
  }
}

/// Tepada 250, pastda 0 — avvalgidek qadam (12 bo‘lak, 13 ta belgi).
List<int> _fixedYAxisLabels250TopToBottom() {
  return List<int>.generate(
    13,
    (i) => (kVendorChartYMaxOrders * (12 - i) / 12).round(),
  );
}

double _measureYAxisLabelsWidth(BuildContext context, List<int> labels) {
  var w = 0.0;
  final style = AppTextStyle.regular12(context, color: StaticColors.black);
  for (final v in labels) {
    final tp = TextPainter(
      text: TextSpan(text: '$v', style: style),
      textDirection: Directionality.of(context),
    )..layout();
    w = math.max(w, tp.width);
  }
  return w + 6;
}

class _ChartYAxis extends StatelessWidget {
  const _ChartYAxis({required this.labels, required this.width});

  final List<int> labels;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 320,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final label in labels)
            Text(
              '$label',
              style: AppTextStyle.regular12(context, color: StaticColors.black),
            ),
        ],
      ),
    );
  }
}

class _ChartDropdown<T> extends StatelessWidget {
  const _ChartDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final T value;
  final List<T> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD0D7F0)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          borderRadius: BorderRadius.circular(12),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: StaticColors.c9AA0A6,
          ),
          style: AppTextStyle.regular12(context, color: StaticColors.c4C4C4C),
          dropdownColor: StaticColors.white,
          onChanged: onChanged,
          items: [
            for (final item in items)
              DropdownMenuItem<T>(value: item, child: Text(item.toString())),
          ],
        ),
      ),
    );
  }
}
