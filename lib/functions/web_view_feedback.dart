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
        title: const Text('Ilovadan chiqilsinmi?'),
        content: const Text('Orqaga qaytish uchun sahifalar qolmadi. Ilovani yopishni xohlaysizmi?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Bekor qilish'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Chiqish'),
          ),
        ],
      );
    },
  );

  return shouldExit ?? false;
}
