import 'package:halalhub_restaurant/core/di/injection.dart';
import 'package:halalhub_restaurant/core/network/network_exception.dart';
import 'package:halalhub_restaurant/core/router/app_router.dart';
import 'package:halalhub_restaurant/features/restaurant/data/repositories/restaurant_repo.dart';

/// Login muvaffaqiyatidan keyin `/vendors/me/` chaqiriladi:
/// — **200 / vendor bor** → [VendorProfileRoute]
/// — **400 yoki 404** (vendor hali yo‘q) → [CreateRestaurantRoute]
/// — **500+** → [ServerErrorRoute]
/// — boshqa xato → [DefaultFallbackRoute]
Future<void> navigateAfterLoginCheckingVendor() async {
  final router = getIt<AppRouter>();
  try {
    await getIt<RestaurantRepo>().getVendorMe();
    await router.replace(const VendorProfileRoute());
  } catch (e) {
    final code = e is NetworkException ? e.statusCode : null;
    if (code == 400 || code == 404) {
      await router.replace(CreateRestaurantRoute());
      return;
    }
    if ((code ?? 0) >= 500) {
      await router.replace(const ServerErrorRoute());
      return;
    }
    await router.replace(const DefaultFallbackRoute());
  }
}

/// Ro‘yxatdan o‘tish (OTP tasdiqlangan) — yangi vendor uchun doimiy ravishda yaratish sahifasi.
Future<void> navigateAfterRegistrationToCreateRestaurant() async {
  await getIt<AppRouter>().replace(CreateRestaurantRoute());
}

/// Tasdiq kutish ekranidagi refresh: `/vendors/me/` — `is_active == true` bo‘lsa asosiy profilga o‘tadi.
Future<void> refreshVendorMeAndGoToProfileIfActive() async {
  final router = getIt<AppRouter>();
  final vendor = await getIt<RestaurantRepo>().getVendorMe();
  if (vendor.isActive == true) {
    await router.replace(const VendorProfileRoute());
  }
}
