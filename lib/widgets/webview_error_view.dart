import 'package:flutter/material.dart';

class WebViewErrorView extends StatelessWidget {
  const WebViewErrorView({
    required this.message,
    required this.onRetry,
    super.key,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ColoredBox(
      color: theme.colorScheme.surface,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: <Widget>[
              Icon(
                Icons.wifi_off_rounded,
                size: 56,
                color: theme.colorScheme.primary,
              ),
              Text(
                'Sahifa yuklanmadi',
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              Text(
                message,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Qayta urinish'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
