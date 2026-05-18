import 'package:flutter/material.dart';

class FinanceTransactionStatusColors {
  const FinanceTransactionStatusColors({
    required this.background,
    required this.foreground,
  });

  final Color background;
  final Color foreground;
}

String financeTransactionOrderLabel(String orderNumber) {
  final trimmed = orderNumber.trim();
  if (trimmed.isEmpty) return '#';
  return trimmed.startsWith('#') ? trimmed : '#$trimmed';
}

String formatFinanceTransactionMoney(String raw) {
  final trimmed = raw.trim();
  if (trimmed.startsWith('\$')) return trimmed;
  return '\$$trimmed';
}

String capitalizeFinanceTransactionLabel(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return '';
  return '${trimmed[0].toUpperCase()}${trimmed.substring(1).toLowerCase()}';
}

/// Sana/vaqt bir qatorda qolishi uchun AM/PM oldidagi bo'shliqni NBSP qiladi.
String financeTransactionDisplayDate(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return trimmed;
  return trimmed.replaceAllMapped(
    RegExp(r'\s+(AM|PM)\b', caseSensitive: false),
    (m) => '\u00A0${m.group(1)}',
  );
}

String shortFinanceTransactionStatusLabel(String statusDisplay) {
  final trimmed = statusDisplay.trim();
  if (trimmed.isEmpty) return '';
  final beforeParen = trimmed.split('(').first.trim();
  return beforeParen.isEmpty ? trimmed : beforeParen;
}

FinanceTransactionStatusColors financeTransactionStatusColors(String status) {
  switch (status.toLowerCase()) {
    case 'pending':
    case 'created':
      return const FinanceTransactionStatusColors(
        background: Color(0xFFFFF4E5),
        foreground: Color(0xFFD97706),
      );
    case 'cancelled':
    case 'canceled':
      return const FinanceTransactionStatusColors(
        background: Color(0xFFFEE2E2),
        foreground: Color(0xFFDC2626),
      );
    default:
      return const FinanceTransactionStatusColors(
        background: Color(0xFFDCFCE7),
        foreground: Color(0xFF16A34A),
      );
  }
}
