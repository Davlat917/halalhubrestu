import 'package:flutter/material.dart';

class WebViewProgressBar extends StatelessWidget {
  const WebViewProgressBar({
    required this.progress,
    super.key,
  });

  final double progress;

  @override
  Widget build(BuildContext context) {
    if (progress <= 0 || progress >= 1) {
      return const SizedBox.shrink();
    }

    return LinearProgressIndicator(value: progress, minHeight: 3);
  }
}
