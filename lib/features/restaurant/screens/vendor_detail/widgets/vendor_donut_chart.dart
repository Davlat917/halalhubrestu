import 'dart:math' as math;

import 'package:flutter/material.dart';

class VendorDonutChart extends StatelessWidget {
  const VendorDonutChart({
    super.key,
    required this.segments,
  });

  final List<(double, Color)> segments;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _VendorDonutPainter(segments: segments),
      child: const SizedBox.expand(),
    );
  }
}

class _VendorDonutPainter extends CustomPainter {
  _VendorDonutPainter({required this.segments});

  final List<(double, Color)> segments;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 20;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final safeSegments = segments.where((e) => e.$1 > 0).toList();
    if (safeSegments.isEmpty) return;

    final total = safeSegments.fold<double>(0, (sum, item) => sum + item.$1);
    if (total <= 0) return;

    var start = -math.pi / 2;
    for (final s in safeSegments) {
      final paint = Paint()
        ..color = s.$2
        ..style = PaintingStyle.stroke
        ..strokeWidth = 24
        ..strokeCap = StrokeCap.round;
      final sweep = (s.$1 / total) * 2 * math.pi;
      canvas.drawArc(rect, start, sweep, false, paint);
      start += sweep + 0.04;
    }
  }

  @override
  bool shouldRepaint(covariant _VendorDonutPainter oldDelegate) =>
      oldDelegate.segments != segments;
}
