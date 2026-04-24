/// [orderId] — `VendorOrderUiModel.id` (masalan `32313` yoki `ORD-5D0E5F19`).
bool orderIdMatchesSearch(String orderId, String query) {
  final q = query.trim().toLowerCase().replaceAll('#', '').replaceAll(RegExp(r'\s+'), '');
  if (q.isEmpty) return true;
  final id = orderId.trim().toLowerCase().replaceAll('#', '').replaceAll(RegExp(r'\s+'), '');
  return id.contains(q);
}
