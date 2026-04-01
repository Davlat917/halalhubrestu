import 'package:flutter/material.dart';

class NotInternetPage extends StatelessWidget {
  const NotInternetPage({
    super.key,
    required this.onRetry,
    required this.isLoading,
  });

  final VoidCallback onRetry;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ColoredBox(
      color: theme.colorScheme.surface,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.wifi_off_rounded,
                size: 72,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                "Internet unavailable",
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                "Check the network and try again.",
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: isLoading ? null : onRetry,
                icon: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh_rounded),
                label: Text(isLoading ? "Checking..." : "Try again"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
