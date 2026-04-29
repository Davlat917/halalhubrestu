class Constants {
  // map api key
  static const mapApiKey = 'AIzaSyDvA7oUFBIZE_FkQ107PRJU7GH9V5BHBoE';

  // base url
  // static const baseUrl = 'https://infonexuz.uz';
  static const baseUrl = 'https://backend-api.wehalalhub.com';
  static const version = '/api/v1';

  // accaunts
  static const accounts = "/accounts";
  static const refreshToken = "$accounts/email/token/refresh/";

  static const signupPhone = "$accounts/signup/phone/";
  static const signupEmail = "$accounts/signup/email/";
  static const verifyOtp = "$accounts/verify-otp/";
  static const resetOtpRequest = "$accounts/reset-otp/request/";
  static const loginEmail = "$accounts/email/login/";
  static const passwordResetRequest = "$accounts/password-reset/request/";
  static const passwordResetConfirm = "$accounts/password-reset/confirm/";
  static const passwordResetVerify = "$accounts/password-reset/verify/";
  static const googleLogin = "$accounts/google/";
  static const appleLogin = "$accounts/apple/";
  static const updateRole = "$accounts/update/role/";

  // vendor
  static const vendorsCreate = "/vendors/create/";
  static const vendorsMe = "/vendors/me/";
  static const vendorsCategories = "/vendors/categories/";
  static const vendorsIngredients = "/vendors/ingredients/";
  static const vendorsProducts = "/vendors/products/";
  static const vendorsFinanceOverview = "/vendors/vendor/finance/overview/";
  static const vendorsFinancePerformance =
      "/vendors/vendor/finance/performance/";
  static const vendorsFinanceTopCustomers =
      "/vendors/vendor/finance/top-customers/";
  static const vendorsFinanceSalesDistribution =
      "/vendors/vendor/finance/sales-distribution/";
  static const vendorsWalletDashboard = "/vendors/wallet/dashboard/";
  static const vendorsBankInfo = "/vendors/bank-info/";
  static const vendorsPayoutRequests = "/vendors/payout-requests/";
  static String vendorsProductsByVendorId(int vendorId) =>
      "/vendors/vendors/$vendorId/products/";
  static String vendorsProductDetailByVendorId(int vendorId, int productId) =>
      "/vendors/vendors/$vendorId/products/$productId/";

  /// Joriy vendorning video clip’lari (GET, POST upload).
  static const vendorsVendorMedia = "/vendors/vendor/media/";
  static String vendorsVendorMediaById(int mediaId) =>
      "/vendors/vendor/media/$mediaId/";

  /// Bildirishnomalar (pagination: `next` / `previous`).
  static const coreNotifications = "/core/notifications/";
  static const coreDevices = "/core/devices/";
  static String vendorAgreement(int vendorId) =>
      "/core/vendors/$vendorId/agreement/";
  static String vendorAgreementAcceptStep(int vendorId) =>
      "/core/vendors/$vendorId/agreement/accept-step/";
  static String vendorAgreementSign(int vendorId) =>
      "/core/vendors/$vendorId/agreement/sign/";
  static String vendorAgreementDownload(int vendorId) =>
      "/core/vendors/$vendorId/agreement/download/";

  /// Vendor buyurtmalar tarixi (pagination: `next` / `previous`).
  static const vendorsVendorOrderHistory = "/vendors/vendor/order/history/";

  /// Vendorning aktiv buyurtmalari ro'yxati (pagination: `next` / `previous`).
  static const vendorsOrders = "/vendors/orders/";
  static String vendorsOrderDetailById(int id) => "/vendors/orders/vendor/$id/";
  static String vendorsOrderStatusById(int id) => "/vendors/orders/$id/status/";

  /// Vendor POS integratsiyalari (tablet, Clover, Rezku, …).
  static const deliveryVendorPosProviders = "/delivery/vendor/pos/providers/";
  static const deliveryVendorPosSelect = "/delivery/vendor/pos/select/";

  /// Clover OAuth boshlash (authorize_url qaytaradi).
  static const deliveryCloverConnect = "/delivery/clover/connect/";
}
