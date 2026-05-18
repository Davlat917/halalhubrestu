/// Finance transactions API `period` query param.
enum VendorFinancePeriod {
  daily('daily'),
  weekly('weekly'),
  monthly('monthly'),
  yearly('yearly');

  const VendorFinancePeriod(this.apiValue);

  final String apiValue;

  static VendorFinancePeriod fromApiValue(String? raw) {
    final normalized = raw?.trim().toLowerCase() ?? '';
    return VendorFinancePeriod.values.firstWhere(
      (p) => p.apiValue == normalized,
      orElse: () => VendorFinancePeriod.weekly,
    );
  }
}
