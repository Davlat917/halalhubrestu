import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_create/vendor_create_model.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_category/vendor_category_model.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_finance_performance/vendor_finance_performance_model.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_finance_overview/vendor_finance_overview_model.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_bank_info/vendor_bank_info_model.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_sales_distribution/vendor_sales_distribution_model.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_top_customer/vendor_top_customer_model.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_ingredient/vendor_ingredient_model.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_me/vendor_me_model.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_media_clip/vendor_media_clip_model.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_product/vendor_product_model.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_payout_request/vendor_payout_request_model.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_wallet_dashboard/vendor_wallet_dashboard_model.dart';
import 'package:image_picker/image_picker.dart';

abstract class RestaurantRepo {
  Future<VendorMeModel> getVendorMe();
  Future<List<VendorCategoryModel>> getVendorCategories();
  Future<List<VendorIngredientModel>> getVendorIngredients();
  Future<List<VendorProductGroupModel>> getVendorProductsByVendorId(
    int vendorId,
  );
  Future<VendorFinanceOverviewModel> getVendorFinanceOverview();
  Future<VendorFinancePerformanceModel> getVendorFinancePerformance();
  Future<List<VendorTopCustomerModel>> getVendorFinanceTopCustomers();
  Future<List<VendorSalesDistributionModel>>
  getVendorFinanceSalesDistribution();
  Future<VendorWalletDashboardModel> getVendorWalletDashboard();
  Future<VendorBankInfoModel> getVendorBankInfo();

  /// [url] — `null` bo‘lsa birinchi sahifa, aks holda API `next` havolasi.
  Future<VendorPayoutRequestsPageResult> getVendorPayoutRequests({String? url});

  /// Yangi payout so‘rovi (masalan `"50.00"`).
  Future<VendorPayoutRequestModel> createVendorPayoutRequest({
    required String requestedAmount,
  });

  Future<VendorBankInfoModel> updateVendorBankInfo({
    required String businessName,
    required String payoutSchedule,
    required String einNumber,
    required String accountNumber,
    required String routingNumber,
  });

  /// [url] — `null` bo‘lsa birinchi sahifa, aks holda API `next` havolasi.
  Future<VendorMediaPageResult> getVendorMedia({String? url});
  Future<void> uploadVendorMedia({
    required XFile videoFile,
    required String description,
  });
  Future<void> updateVendorMediaDescription({
    required int mediaId,
    required String description,
  });
  Future<void> createVendorProduct({
    required String name,
    required int preparationTime,
    double? price,
    String? description,
    bool isAvailable = true,
    List<int> categories = const [],
    List<String> newIngredients = const [],
    String? discountsJson,
    String? deletedImageIds,
    List<XFile> newImages = const [],
  });
  Future<void> updateVendorProduct({
    required int vendorId,
    required int productId,
    required String name,
    required int preparationTime,
    double? price,
    String? description,
    bool? isAvailable,
    List<int> categories = const [],
    List<String> newIngredients = const [],
    String? discountsJson,
    String? deletedImageIds,
    List<XFile> newImages = const [],
  });

  Future<VendorMeModel> vendorUpdate({
    required VendorCreateModel payload,
    List<int> categoryIds = const [],
    List<int> deletedCertificateIds = const [],
    String? avgDeliveryTime,
    bool deleteLogo = false,
    bool deleteBanner = false,
    XFile? profileImage,
    XFile? bannerImage,
    List<XFile> certificateFiles = const [],
  });

  Future<VendorCreateModel> vendorCreate({
    required VendorCreateModel payload,
    XFile? profileImage,
    XFile? bannerImage,
    List<XFile> certificateFiles = const [],
  });
}
