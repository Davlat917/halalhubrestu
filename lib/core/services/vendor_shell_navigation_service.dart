import 'package:injectable/injectable.dart';

/// [VendorProfileScaffold] ochiq bo‘lganda Orders tabini tanlash uchun callback.
@lazySingleton
class VendorShellNavigationService {
  void Function()? _openOrdersTab;
  bool _ordersTabActive = false;
  /// `true` — ustida boshqa route (masalan Notification) ochilgan; vendor shell ko‘rinmayapti.
  bool _vendorShellCovered = false;

  /// Vendor kabinetda **Buyurtmalar** tabi tanlangan (yoki default ochilganda).
  bool get isOrdersTabActive => _ordersTabActive;

  void setOrdersTabActive(bool value) {
    _ordersTabActive = value;
  }

  void setVendorShellCovered(bool value) {
    _vendorShellCovered = value;
  }

  /// Yangi buyurtma dialogi: faqat buyurtmalar tabi **ko‘rinib turganida** yashiriladi.
  bool get shouldSuppressNewOrderDialog =>
      !_vendorShellCovered && _ordersTabActive;

  void attachOpenOrdersTab(void Function() handler) {
    _openOrdersTab = handler;
  }

  void detachOpenOrdersTab() {
    _openOrdersTab = null;
  }

  /// true = vendor kabinet ichida tab almashtirildi.
  bool tryOpenOrdersTab() {
    final h = _openOrdersTab;
    if (h == null) return false;
    h();
    return true;
  }
}
