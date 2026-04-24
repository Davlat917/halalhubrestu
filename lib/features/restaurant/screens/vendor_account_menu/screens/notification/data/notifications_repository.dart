import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/notification/data/models/notifications_page_result.dart';

abstract class NotificationsRepository {
  /// [nextPageUrl] — API `next` to‘liq URL; `null` bo‘lsa birinchi sahifa.
  Future<NotificationsPageResult> fetchNotifications({String? nextPageUrl});
}
