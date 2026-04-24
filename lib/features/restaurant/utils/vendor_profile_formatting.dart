import 'package:easy_localization/easy_localization.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_me/vendor_me_model.dart';

const _weekdayOrder = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

String? effectiveImageUrl(String? primary, String? fallback) {
  final u = primary ?? fallback;
  if (u == null || u.trim().isEmpty) return null;
  return u;
}

VendorWorkdayMe? workdayForToday(List<VendorWorkdayMe> workdays) {
  if (workdays.isEmpty) return null;
  final weekday = DateTime.now().weekday;
  final name = _weekdayOrder[weekday - 1];
  for (final w in workdays) {
    if (w.day == name) return w;
  }
  return null;
}

/// Backend `HH:mm:ss` → `h:mm AM/PM` (locale-agnostic, English labels).
String? formatWorkdayLine(VendorWorkdayMe? day) {
  if (day == null) return null;
  final from = _formatTime(day.fromTime);
  final to = _formatTime(day.toTime);
  final status = day.status ?? '';
  final isClosed =
      status.toLowerCase() == 'closed' ||
      (day.currentStatus ?? '').toLowerCase() == 'closed';
  if (isClosed || from == null || to == null) {
    return TranslationKeys.vendorProfileTodayClosed.tr();
  }
  return TranslationKeys.vendorProfileTodayHours.tr(
    namedArgs: {'from': from, 'to': to},
  );
}

String? _formatTime(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  final parts = raw.split(':');
  if (parts.length < 2) return raw;
  final h = int.tryParse(parts[0]) ?? 0;
  final m = int.tryParse(parts[1]) ?? 0;
  final isPm = h >= 12;
  final hour12 = h % 12 == 0 ? 12 : h % 12;
  final ampm = isPm ? 'PM' : 'AM';
  final mm = m.toString().padLeft(2, '0');
  return '$hour12:$mm $ampm';
}

String ratingLabel(VendorMeModel v) {
  final r = v.ratingAvg ?? '0';
  final votes = v.votes ?? 0;
  return '$r ($votes+)';
}
