import 'package:flutter/material.dart';

/// Uch bosqichli gorizontal progress (dizayndagi uch tugun).
class OrderProgressTracker extends StatelessWidget {
  const OrderProgressTracker({
    super.key,
    required this.activeNodes,
    required this.activeColor,
  }) : assert(activeNodes >= 0 && activeNodes <= 3);

  /// Chapdan boshlab nechta tugun to‘ldirilgan (0–3).
  final int activeNodes;
  final Color activeColor;

  static const _nodeSize = 10.0;
  static const _lineHeight = 3.0;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _node(0),
        Expanded(child: _segment(0)),
        _node(1),
        Expanded(child: _segment(1)),
        _node(2),
      ],
    );
  }

  Widget _node(int index) {
    final filled = index < activeNodes;
    return Container(
      width: _nodeSize,
      height: _nodeSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? activeColor : OrderProgressTracker._inactiveFill,
        border: Border.all(
          color: filled ? activeColor : OrderProgressTracker._inactiveBorder,
          width: 1,
        ),
      ),
    );
  }

  Widget _segment(int segmentIndex) {
    final leftNode = segmentIndex + 1;
    final filled = leftNode < activeNodes;
    return Align(
      alignment: Alignment.center,
      child: Container(
        height: _lineHeight,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: filled ? activeColor : OrderProgressTracker._inactiveFill,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  static const _inactiveFill = Color(0xFFE8E8E8);
  static const _inactiveBorder = Color(0xFFD0D0D0);
}
