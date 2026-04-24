import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_finance_performance/vendor_finance_performance_model.dart';

class VendorAreaChartPainterWidget extends StatelessWidget {
  const VendorAreaChartPainterWidget({
    super.key,
    required this.points,
    required this.maxYValue,
    required this.isLoading,
    required this.selectedIndex,
    required this.onSelectIndex,
  });

  final List<VendorFinancePerformancePointModel> points;
  /// Y o‘qi masshtabi: buyurtmalar soni (0 … maxYValue).
  final double maxYValue;
  final bool isLoading;
  final int? selectedIndex;
  final ValueChanged<int> onSelectIndex;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) {
            if (points.isEmpty || width <= 0) return;
            final step = points.length == 1 ? width : width / (points.length - 1);
            final raw = (details.localPosition.dx / step).round();
            final index = raw.clamp(0, points.length - 1);
            onSelectIndex(index);
          },
          child: CustomPaint(
            painter: _VendorAreaChartPainter(
              points: points,
              maxYValue: maxYValue,
              isLoading: isLoading,
              selectedIndex: selectedIndex,
            ),
            child: const SizedBox.expand(),
          ),
        );
      },
    );
  }
}

int _defaultMarkerIndex(List<VendorFinancePerformancePointModel> points) {
  if (points.isEmpty) return 0;
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
  return math.min(points.length - 1, math.max(0, now.day - 1));
}

/// Catmull–Rom → kubik Bezier: har bir nuqtadan o‘tadi, o‘sish/pasayishlar silliq,
/// ikki nuqta orasidagi eski `cubicTo(midX, …)` dagi notabiiy S-egri yo‘q.
Path _catmullRomSplinePath(List<Offset> pts) {
  if (pts.isEmpty) return Path();
  if (pts.length == 1) {
    return Path()..moveTo(pts[0].dx, pts[0].dy);
  }
  if (pts.length == 2) {
    return Path()
      ..moveTo(pts[0].dx, pts[0].dy)
      ..lineTo(pts[1].dx, pts[1].dy);
  }

  Offset extrapolateBefore(Offset a, Offset b) =>
      Offset(2 * a.dx - b.dx, 2 * a.dy - b.dy);
  Offset extrapolateAfter(Offset a, Offset b) =>
      Offset(2 * b.dx - a.dx, 2 * b.dy - a.dy);

  final path = Path()..moveTo(pts[0].dx, pts[0].dy);
  for (var i = 0; i < pts.length - 1; i++) {
    final p0 = i == 0 ? extrapolateBefore(pts[0], pts[1]) : pts[i - 1];
    final p1 = pts[i];
    final p2 = pts[i + 1];
    final p3 = i + 2 < pts.length
        ? pts[i + 2]
        : extrapolateAfter(pts[pts.length - 2], pts[pts.length - 1]);

    final cp1x = p1.dx + (p2.dx - p0.dx) / 6;
    final cp1y = p1.dy + (p2.dy - p0.dy) / 6;
    final cp2x = p2.dx - (p3.dx - p1.dx) / 6;
    final cp2y = p2.dy - (p3.dy - p1.dy) / 6;

    path.cubicTo(cp1x, cp1y, cp2x, cp2y, p2.dx, p2.dy);
  }
  return path;
}

class _VendorAreaChartPainter extends CustomPainter {
  _VendorAreaChartPainter({
    required this.points,
    required this.maxYValue,
    required this.isLoading,
    required this.selectedIndex,
  });

  final List<VendorFinancePerformancePointModel> points;
  final double maxYValue;
  final bool isLoading;
  final int? selectedIndex;

  @override
  void paint(Canvas canvas, Size size) {
    final chartBottomPadding = 24.0;
    final chartHeight = size.height - chartBottomPadding;
    final chartWidth = size.width;
    final maxY = maxYValue <= 0 ? 1.0 : maxYValue;

    final gridPaint = Paint()
      ..color = StaticColors.cE2E2E2.withAlpha(120)
      ..strokeWidth = 1;
    for (var i = 0; i <= 10; i++) {
      final y = chartHeight * (i / 10);
      canvas.drawLine(Offset(0, y), Offset(chartWidth, y), gridPaint);
    }
    final xSections = math.max(1, points.isEmpty ? 30 : points.length - 1);
    for (var i = 0; i <= xSections; i++) {
      final x = chartWidth * (i / xSections);
      canvas.drawLine(Offset(x, 0), Offset(x, chartHeight), gridPaint);
    }

    final chartPoints = <Offset>[];
    final length = points.isEmpty ? 1 : points.length;
    for (var i = 0; i < length; i++) {
      final point = points.isEmpty ? null : points[i];
      final x = length == 1 ? chartWidth / 2 : (chartWidth / (length - 1)) * i;
      final orders = point?.ordersCount.toDouble() ?? 0;
      final clamped = orders.clamp(0.0, maxY);
      final y = chartHeight * (1 - (clamped / maxY));
      chartPoints.add(Offset(x, y));
    }

    final path = _catmullRomSplinePath(chartPoints);

    final fillPath = Path.from(path)
      ..lineTo(chartWidth, chartHeight)
      ..lineTo(0, chartHeight)
      ..close();
    final gradient = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xB30DA84A), Color(0x120DA84A)],
      ).createShader(Rect.fromLTWH(0, 0, chartWidth, chartHeight));
    canvas.drawPath(fillPath, gradient);

    final stroke = Paint()
      ..color = StaticColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawPath(path, stroke);

    final markerIndex = _activeMarkerIndex();
    final marker = chartPoints[markerIndex];
    canvas.drawCircle(marker, 4, Paint()..color = StaticColors.primary);

    if (!isLoading && points.isNotEmpty) {
      final markerPoint = points[markerIndex];
      final bubbleRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          math.max(8, marker.dx - 70),
          math.max(8, marker.dy - 66),
          140,
          48,
        ),
        const Radius.circular(10),
      );
      canvas.drawRRect(
        bubbleRect,
        Paint()..color = StaticColors.c4C4C4C.withAlpha(220),
      );
      final textPainter = TextPainter(
        text: TextSpan(
          children: [
            TextSpan(
              text: '${_formatDate(markerPoint.date)}: ',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            TextSpan(
              text: '${markerPoint.ordersCount}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextSpan(
              text: '\n\$${markerPoint.revenue}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout(maxWidth: 132);
      textPainter.paint(
        canvas,
        Offset(
          bubbleRect.left + (bubbleRect.width - textPainter.width) / 2,
          bubbleRect.top + (bubbleRect.height - textPainter.height) / 2,
        ),
      );
    }

    final labelStyle = TextStyle(
      color: StaticColors.c4C4C4C.withAlpha(200),
      fontSize: 11,
      fontWeight: FontWeight.w400,
    );
    final labelsCount = points.isEmpty ? 30 : points.length;
    for (var i = 0; i < labelsCount; i++) {
      final day = points.isEmpty ? i + 1 : points[i].day;
      final x = labelsCount == 1 ? chartWidth / 2 : (chartWidth / (labelsCount - 1)) * i;
      final tp = TextPainter(
        text: TextSpan(text: '$day', style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, chartHeight + 4));
    }
  }

  @override
  bool shouldRepaint(covariant _VendorAreaChartPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.maxYValue != maxYValue ||
        oldDelegate.isLoading != isLoading ||
        oldDelegate.selectedIndex != selectedIndex;
  }

  int _activeMarkerIndex() {
    if (points.isEmpty) return 0;
    if (selectedIndex != null &&
        selectedIndex! >= 0 &&
        selectedIndex! < points.length) {
      return selectedIndex!;
    }
    return _defaultMarkerIndex(points);
  }

  String _formatDate(String value) {
    final parts = value.split('-');
    if (parts.length != 3) return value;
    return '${parts[2]}.${parts[1]}.${parts[0]}';
  }
}
