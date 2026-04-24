import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';

/// `created_at` uchun qisqa matn (masalan: "20 minutes ago").
String notificationRelativeTime(BuildContext context, DateTime? at) {
  if (at == null) return '';
  final local = at.toLocal();
  final diff = DateTime.now().difference(local);
  if (diff.isNegative) {
    return TranslationKeys.notificationJustNow.tr(context: context);
  }
  if (diff.inSeconds < 60) {
    return TranslationKeys.notificationJustNow.tr(context: context);
  }
  if (diff.inMinutes < 60) {
    final m = diff.inMinutes;
    return m == 1
        ? TranslationKeys.notificationMinuteAgo.tr(context: context)
        : TranslationKeys.notificationMinutesAgo.tr(
            context: context,
            namedArgs: {'count': '$m'},
          );
  }
  if (diff.inHours < 24) {
    final h = diff.inHours;
    return h == 1
        ? TranslationKeys.notificationHourAgo.tr(context: context)
        : TranslationKeys.notificationHoursAgo.tr(
            context: context,
            namedArgs: {'count': '$h'},
          );
  }
  if (diff.inDays < 7) {
    final d = diff.inDays;
    return d == 1
        ? TranslationKeys.notificationDayAgo.tr(context: context)
        : TranslationKeys.notificationDaysAgo.tr(
            context: context,
            namedArgs: {'count': '$d'},
          );
  }
  if (diff.inDays < 30) {
    final w = diff.inDays ~/ 7;
    return w == 1
        ? TranslationKeys.notificationWeekAgo.tr(context: context)
        : TranslationKeys.notificationWeeksAgo.tr(
            context: context,
            namedArgs: {'count': '$w'},
          );
  }
  final mo = diff.inDays ~/ 30;
  return mo <= 1
      ? TranslationKeys.notificationMonthAgo.tr(context: context)
      : TranslationKeys.notificationMonthsAgo.tr(
          context: context,
          namedArgs: {'count': '$mo'},
        );
}
