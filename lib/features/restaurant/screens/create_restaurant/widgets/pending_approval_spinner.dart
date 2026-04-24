import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';

class PendingApprovalSpinner extends StatefulWidget {
  const PendingApprovalSpinner({super.key});

  @override
  State<PendingApprovalSpinner> createState() => _PendingApprovalSpinnerState();
}

class _PendingApprovalSpinnerState extends State<PendingApprovalSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: const Icon(
        Icons.hourglass_empty_rounded,
        color: StaticColors.primary,
      ),
    );
  }
}
