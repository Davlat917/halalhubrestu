enum PaymentStatus { verified, pending, failed }

class PaymentHistoryRowData {
  const PaymentHistoryRowData(
    this.id,
    this.date,
    this.status,
    this.amount, {
    this.statusLabel,
  });

  final String id;
  final String date;
  final PaymentStatus status;

  /// Masalan `\$10.00` — API `requested_amount` dan.
  final String amount;

  /// API `status_display` — berilsa badge shu matnni ko‘rsatadi.
  final String? statusLabel;
}
