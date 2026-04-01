import 'package:flutter/material.dart';

Future<void> showWebViewFailureSnackBar(BuildContext context, String message) async {
  final messenger = ScaffoldMessenger.of(context);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

Future<bool> showExitDialog(BuildContext context) async {
  final shouldExit = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Exit app?'),
        content: const Text('No pages left to go back. Do you want to close the app?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Exit'),
          ),
        ],
      );
    },
  );

  return shouldExit ?? false;
}
