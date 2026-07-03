double? parsePriceValue(String? raw) {
  if (raw == null) return null;
  var cleaned = raw.trim();
  if (cleaned.isEmpty) return null;

  cleaned = cleaned
      .replaceAll(' ', '')
      .replaceAll('\$', '')
      .replaceAll(',', '.')
      .replaceAll(RegExp(r'[^0-9.]'), '');

  final firstDot = cleaned.indexOf('.');
  if (firstDot != -1) {
    final before = cleaned.substring(0, firstDot + 1);
    final after = cleaned.substring(firstDot + 1).replaceAll('.', '');
    cleaned = '$before$after';
  }

  return double.tryParse(cleaned);
}

int? parsePreparationTimeMinutes(String? raw) {
  if (raw == null) return null;
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return null;
  final match = RegExp(r'\d+').firstMatch(trimmed);
  if (match == null) return null;
  return int.tryParse(match.group(0)!);
}
