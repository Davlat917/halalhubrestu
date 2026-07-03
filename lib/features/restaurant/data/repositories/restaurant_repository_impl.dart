import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:halalhub_restaurant/core/constants/constants.dart';
import 'package:halalhub_restaurant/core/network/network_exception.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_category/vendor_category_model.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_create/vendor_create_model.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_finance_performance/vendor_finance_performance_model.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_finance_overview/vendor_finance_overview_model.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_bank_info/vendor_bank_info_model.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_sales_distribution/vendor_sales_distribution_model.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_stripe_check/vendor_stripe_check_model.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_stripe_connect/vendor_stripe_connect_model.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_top_customer/vendor_top_customer_model.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_payout_request/vendor_payout_request_model.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_wallet_dashboard/vendor_wallet_dashboard_model.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_ingredient/vendor_ingredient_model.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_media_clip/vendor_media_clip_model.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_me/vendor_me_model.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_product/vendor_product_model.dart';
import 'package:halalhub_restaurant/features/restaurant/data/repositories/restaurant_repo.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: RestaurantRepo)
class RestaurantRepositoryImpl extends RestaurantRepo {
  RestaurantRepositoryImpl(this._dio);

  final Dio _dio;

  Future<FormData> _buildVendorFormData({
    required VendorCreateModel payload,
    List<int> categoryIds = const [],
    List<int> deletedCertificateIds = const [],
    String? avgDeliveryTime,
    bool deleteLogo = false,
    bool deleteBanner = false,
    XFile? profileImage,
    XFile? bannerImage,
    List<XFile> certificateFiles = const [],
  }) async {
    final body = payload.toJson()..removeWhere((k, v) => v == null);
    final baseData = <String, dynamic>{
      ...body
        ..remove('workdays')
        ..remove('categories')
        ..remove('certificate_files'),
    };

    final formData = FormData();
    baseData.forEach((key, value) {
      if (value != null) {
        formData.fields.add(MapEntry(key, value.toString()));
      }
    });

    final effectiveCategoryIds = categoryIds.isNotEmpty
        ? categoryIds
        : (payload.categories ?? const <int>[]);
    if (effectiveCategoryIds.isNotEmpty) {
      for (final categoryId in effectiveCategoryIds) {
        formData.fields.add(MapEntry('category_ids', categoryId.toString()));
      }
    }
    if (deletedCertificateIds.isNotEmpty) {
      for (final id in deletedCertificateIds) {
        formData.fields.add(MapEntry('deleted_certificate_ids', id.toString()));
      }
    }
    if (avgDeliveryTime != null && avgDeliveryTime.isNotEmpty) {
      formData.fields.add(MapEntry('avg_delivery_time', avgDeliveryTime));
    }

    if (payload.workdays != null && payload.workdays!.isNotEmpty) {
      for (var i = 0; i < payload.workdays!.length; i++) {
        final w = payload.workdays![i];
        formData.fields.add(MapEntry('workdays[$i]day', w.day ?? ''));
        formData.fields.add(
          MapEntry('workdays[$i]from_time', w.fromTime ?? ''),
        );
        formData.fields.add(MapEntry('workdays[$i]to_time', w.toTime ?? ''));
        formData.fields.add(MapEntry('workdays[$i]status', w.status ?? ''));
      }
    }

    if (profileImage != null) {
      formData.files.add(
        MapEntry(
          'logo',
          await MultipartFile.fromFile(
            profileImage.path,
            filename: profileImage.name,
          ),
        ),
      );
    } else if (deleteLogo) {
      formData.fields.add(const MapEntry('delete_logo', 'true'));
      formData.fields.add(const MapEntry('logo', ''));
    }
    if (bannerImage != null) {
      formData.files.add(
        MapEntry(
          'cover_image',
          await MultipartFile.fromFile(
            bannerImage.path,
            filename: bannerImage.name,
          ),
        ),
      );
    } else if (deleteBanner) {
      formData.fields.add(const MapEntry('delete_cover_image', 'true'));
      formData.fields.add(const MapEntry('cover_image', ''));
    }
    if (certificateFiles.isNotEmpty) {
      for (final file in certificateFiles) {
        formData.files.add(
          MapEntry(
            'certificate_files',
            await MultipartFile.fromFile(file.path, filename: file.name),
          ),
        );
      }
    }
    return formData;
  }

  @override
  Future<VendorMeModel> getVendorMe() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        Constants.vendorsMe,
      );
      final data = response.data;
      if (data != null) {
        final json = Map<String, dynamic>.from(data);
        return compute(_parseVendorMeInIsolate, json);
      }
      throw NetworkException(message: 'Invalid vendor profile response');
    } catch (e) {
      final ex = ExceptionHandler.handleException(e);
      if (ex is NetworkException) throw ex;
      throw NetworkException(message: ex.toString());
    }
  }

  @override
  Future<List<VendorCategoryModel>> getVendorCategories() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        Constants.vendorsCategories,
      );
      final body = response.data;
      if (body == null) return [];
      final results = body['results'];
      if (results is! List) return [];
      final rows = <Map<String, dynamic>>[];
      for (final e in results) {
        if (e is Map) {
          rows.add(Map<String, dynamic>.from(e));
        }
      }
      if (rows.isEmpty) return [];
      return compute(_parseVendorCategoriesInIsolate, rows);
    } catch (e) {
      final ex = ExceptionHandler.handleException(e);
      if (ex is NetworkException) throw ex;
      throw NetworkException(message: ex.toString());
    }
  }

  @override
  Future<List<VendorCategoryModel>> getVendorProductCategories() async {
    try {
      final rows = <Map<String, dynamic>>[];
      String? nextUrl = Constants.vendorsProductCategories;

      while (nextUrl != null && nextUrl.isNotEmpty) {
        final response = await _dio.get<Map<String, dynamic>>(nextUrl);
        final body = response.data;
        if (body == null) break;

        final results = body['results'];
        if (results is List) {
          for (final item in results) {
            if (item is Map) {
              rows.add(Map<String, dynamic>.from(item));
            }
          }
        }

        final next = body['next'];
        if (next is String && next.trim().isNotEmpty) {
          nextUrl = next;
        } else {
          nextUrl = null;
        }
      }

      if (rows.isEmpty) return [];
      return compute(_parseVendorCategoriesInIsolate, rows);
    } catch (e) {
      final ex = ExceptionHandler.handleException(e);
      if (ex is NetworkException) throw ex;
      throw NetworkException(message: ex.toString());
    }
  }

  @override
  Future<List<VendorIngredientModel>> getVendorIngredients() async {
    try {
      final out = <VendorIngredientModel>[];
      String? nextUrl = Constants.vendorsIngredients;

      while (nextUrl != null && nextUrl.isNotEmpty) {
        final response = await _dio.get<Map<String, dynamic>>(nextUrl);
        final body = response.data;
        if (body == null) break;

        final results = body['results'];
        if (results is List) {
          for (final item in results) {
            if (item is Map) {
              out.add(
                VendorIngredientModel.fromJson(Map<String, dynamic>.from(item)),
              );
            }
          }
        }

        final next = body['next'];
        if (next is String && next.trim().isNotEmpty) {
          nextUrl = next;
        } else {
          nextUrl = null;
        }
      }

      return out;
    } catch (e) {
      final ex = ExceptionHandler.handleException(e);
      if (ex is NetworkException) throw ex;
      throw NetworkException(message: ex.toString());
    }
  }

  @override
  Future<List<VendorProductGroupModel>> getVendorProductsByVendorId(
    int vendorId,
  ) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        Constants.vendorsProductsByVendorId(vendorId),
      );
      final body = response.data;
      if (body == null) return const [];

      final results = body['results'];
      if (results is! List) return const [];

      final groups = <VendorProductGroupModel>[];
      for (final categoryBlock in results) {
        if (categoryBlock is! Map) continue;
        groups.add(
          VendorProductGroupModel.fromJson(
            Map<String, dynamic>.from(categoryBlock),
          ),
        );
      }

      return groups;
    } catch (e) {
      final ex = ExceptionHandler.handleException(e);
      if (ex is NetworkException) throw ex;
      throw NetworkException(message: ex.toString());
    }
  }

  @override
  Future<VendorFinanceOverviewModel> getVendorFinanceOverview() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        Constants.vendorsFinanceOverview,
      );
      final body = response.data;
      if (body == null) {
        throw NetworkException(
          message: 'Invalid vendor finance overview response',
        );
      }
      return VendorFinanceOverviewModel.fromJson(
        Map<String, dynamic>.from(body),
      );
    } catch (e) {
      final ex = ExceptionHandler.handleException(e);
      if (ex is NetworkException) throw ex;
      throw NetworkException(message: ex.toString());
    }
  }

  @override
  Future<VendorFinancePerformanceModel> getVendorFinancePerformance() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        Constants.vendorsFinancePerformance,
      );
      final body = response.data;
      if (body == null) {
        throw NetworkException(
          message: 'Invalid vendor finance performance response',
        );
      }
      return VendorFinancePerformanceModel.fromJson(
        Map<String, dynamic>.from(body),
      );
    } catch (e) {
      final ex = ExceptionHandler.handleException(e);
      if (ex is NetworkException) throw ex;
      throw NetworkException(message: ex.toString());
    }
  }

  List<dynamic> _parseTopCustomersList(dynamic body) {
    if (body is List) return body;
    if (body is Map) {
      final map = Map<String, dynamic>.from(body);
      final results = map['results'];
      if (results is List) return results;
    }
    throw NetworkException(
      message: 'Invalid vendor finance top customers response',
    );
  }

  List<dynamic> _parseSalesDistributionList(dynamic body) {
    if (body is List) return body;
    if (body is Map) {
      final map = Map<String, dynamic>.from(body);
      final results = map['results'];
      if (results is List) return results;
    }
    throw NetworkException(
      message: 'Invalid vendor finance sales distribution response',
    );
  }

  @override
  Future<List<VendorTopCustomerModel>> getVendorFinanceTopCustomers() async {
    try {
      final response = await _dio.get<dynamic>(
        Constants.vendorsFinanceTopCustomers,
      );
      final items = _parseTopCustomersList(response.data);
      final out = <VendorTopCustomerModel>[];
      for (final e in items) {
        if (e is Map) {
          out.add(
            VendorTopCustomerModel.fromJson(Map<String, dynamic>.from(e)),
          );
        }
      }
      return out;
    } catch (e) {
      final ex = ExceptionHandler.handleException(e);
      if (ex is NetworkException) throw ex;
      throw NetworkException(message: ex.toString());
    }
  }

  @override
  Future<List<VendorSalesDistributionModel>>
  getVendorFinanceSalesDistribution() async {
    try {
      final response = await _dio.get<dynamic>(
        Constants.vendorsFinanceSalesDistribution,
      );
      final items = _parseSalesDistributionList(response.data);
      final out = <VendorSalesDistributionModel>[];
      for (final e in items) {
        if (e is Map) {
          out.add(
            VendorSalesDistributionModel.fromJson(Map<String, dynamic>.from(e)),
          );
        }
      }
      return out;
    } catch (e) {
      final ex = ExceptionHandler.handleException(e);
      if (ex is NetworkException) throw ex;
      throw NetworkException(message: ex.toString());
    }
  }

  @override
  Future<VendorWalletDashboardModel> getVendorWalletDashboard() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        Constants.vendorsWalletDashboard,
      );
      final body = response.data;
      if (body == null) {
        throw NetworkException(
          message: 'Invalid vendor wallet dashboard response',
        );
      }
      return VendorWalletDashboardModel.fromJson(
        Map<String, dynamic>.from(body),
      );
    } catch (e) {
      final ex = ExceptionHandler.handleException(e);
      if (ex is NetworkException) throw ex;
      throw NetworkException(message: ex.toString());
    }
  }

  @override
  Future<VendorBankInfoModel> getVendorBankInfo() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        Constants.vendorsBankInfo,
      );
      final body = response.data;
      if (body == null) {
        throw NetworkException(message: 'Invalid vendor bank info response');
      }
      return VendorBankInfoModel.fromJson(Map<String, dynamic>.from(body));
    } catch (e) {
      final ex = ExceptionHandler.handleException(e);
      if (ex is NetworkException) throw ex;
      throw NetworkException(message: ex.toString());
    }
  }

  @override
  Future<VendorStripeCheckModel> checkVendorStripe({
    required int vendorId,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        Constants.vendorsVendorCheckStripe(vendorId),
      );
      final body = response.data;
      if (body == null) {
        throw NetworkException(message: 'Invalid Stripe check response');
      }
      return VendorStripeCheckModel.fromJson(Map<String, dynamic>.from(body));
    } catch (e) {
      final ex = ExceptionHandler.handleException(e);
      if (ex is NetworkException) throw ex;
      throw NetworkException(message: ex.toString());
    }
  }

  @override
  Future<VendorStripeConnectModel> connectVendorStripe({
    required String returnUrl,
    required String refreshUrl,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        Constants.vendorsVendorConnectStripe,
        data: {'return_url': returnUrl, 'refresh_url': refreshUrl},
      );
      final body = response.data;
      if (body == null) {
        throw NetworkException(message: 'Invalid Stripe connect response');
      }
      return VendorStripeConnectModel.fromJson(Map<String, dynamic>.from(body));
    } catch (e) {
      final ex = ExceptionHandler.handleException(e);
      if (ex is NetworkException) throw ex;
      throw NetworkException(message: ex.toString());
    }
  }

  @override
  Future<VendorBankInfoModel> updateVendorBankInfo({
    required String businessName,
    required String payoutSchedule,
    String? einNumber,
    String? accountNumber,
    String? routingNumber,
  }) async {
    try {
      final data = <String, dynamic>{
        'business_name': businessName.trim(),
        'payout_schedule': payoutSchedule.trim(),
      };
      if (einNumber != null) {
        data['ein_number'] = einNumber.trim();
      }
      if (accountNumber != null) {
        data['account_number'] = accountNumber.trim();
      }
      if (routingNumber != null) {
        data['routing_number'] = routingNumber.trim();
      }
      final response = await _dio.patch<Map<String, dynamic>>(
        Constants.vendorsBankInfo,
        data: data,
      );
      final body = response.data;
      if (body == null) {
        throw NetworkException(
          message: 'Invalid vendor bank info update response',
        );
      }
      return VendorBankInfoModel.fromJson(Map<String, dynamic>.from(body));
    } catch (e) {
      final ex = ExceptionHandler.handleException(e);
      if (ex is NetworkException) throw ex;
      throw NetworkException(message: ex.toString());
    }
  }

  @override
  Future<VendorPayoutRequestsPageResult> getVendorPayoutRequests({
    String? url,
  }) async {
    final requestPath = url ?? Constants.vendorsPayoutRequests;
    try {
      final response = await _dio.get<Map<String, dynamic>>(requestPath);
      final body = response.data;
      if (body == null) {
        throw NetworkException(message: 'Invalid payout requests response');
      }
      return VendorPayoutRequestsPageResult.fromJson(
        Map<String, dynamic>.from(body),
      );
    } catch (e) {
      final ex = ExceptionHandler.handleException(e);
      if (ex is NetworkException) throw ex;
      throw NetworkException(message: ex.toString());
    }
  }

  @override
  Future<VendorPayoutRequestModel> createVendorPayoutRequest({
    required String requestedAmount,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        Constants.vendorsPayoutRequests,
        data: {'requested_amount': requestedAmount},
      );
      final body = response.data;
      if (body == null) {
        throw NetworkException(message: 'Invalid payout request response');
      }
      return VendorPayoutRequestModel.fromJson(Map<String, dynamic>.from(body));
    } catch (e) {
      final ex = ExceptionHandler.handleException(e);
      if (ex is NetworkException) throw ex;
      throw NetworkException(message: ex.toString());
    }
  }

  @override
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
    String? modifierGroupsJson,
    String? recommendationsJson,
    List<XFile> newImages = const [],
  }) async {
    try {
      final formData = FormData();
      formData.fields.add(MapEntry('name', name));
      formData.fields.add(
        MapEntry('preparation_time', preparationTime.toString()),
      );
      formData.fields.add(MapEntry('is_available', isAvailable.toString()));

      if (price != null) {
        formData.fields.add(MapEntry('price', price.toString()));
      }
      if (description != null && description.trim().isNotEmpty) {
        formData.fields.add(MapEntry('description', description.trim()));
      }
      for (final categoryId in categories) {
        formData.fields.add(MapEntry('categories', categoryId.toString()));
      }
      if (newIngredients.isNotEmpty) {
        final cleanIngredients = newIngredients
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        if (cleanIngredients.isNotEmpty) {
          formData.fields.add(
            MapEntry('new_ingredients', jsonEncode(cleanIngredients)),
          );
        }
      }
      if (discountsJson != null && discountsJson.trim().isNotEmpty) {
        final normalizedDiscounts = _normalizeOptionalJsonField(discountsJson);
        if (normalizedDiscounts != null) {
          formData.fields.add(MapEntry('discounts', normalizedDiscounts));
        }
      }
      if (deletedImageIds != null && deletedImageIds.trim().isNotEmpty) {
        final normalizedDeletedIds = _normalizeOptionalDeletedImageIdsJson(
          deletedImageIds,
        );
        if (normalizedDeletedIds == null) {
          // create productda bu maydon optional: noto'g'ri bo'lsa yubormaymiz
        } else {
          formData.fields.add(
            MapEntry('deleted_image_ids', normalizedDeletedIds),
          );
        }
      }
      _addNormalizedJsonField(
        formData,
        key: 'modifier_groups',
        rawJson: modifierGroupsJson,
      );
      _addNormalizedJsonField(
        formData,
        key: 'recommendations',
        rawJson: recommendationsJson,
      );
      for (final image in newImages) {
        formData.files.add(
          MapEntry(
            'new_images',
            await MultipartFile.fromFile(image.path, filename: image.name),
          ),
        );
      }

      await _dio.post(Constants.vendorsProducts, data: formData);
    } catch (e) {
      final ex = ExceptionHandler.handleException(e);
      if (ex is NetworkException) throw ex;
      throw NetworkException(message: ex.toString());
    }
  }

  @override
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
    String? modifierGroupsJson,
    String? recommendationsJson,
    List<XFile> newImages = const [],
  }) async {
    try {
      final endpoint = Constants.vendorsProductDetailByVendorId(
        vendorId,
        productId,
      );
      final formData = FormData();
      formData.fields.add(MapEntry('name', name));
      formData.fields.add(
        MapEntry('preparation_time', preparationTime.toString()),
      );
      if (isAvailable != null) {
        formData.fields.add(MapEntry('is_available', isAvailable.toString()));
      }

      if (price != null) {
        formData.fields.add(MapEntry('price', price.toString()));
      }
      if (description != null && description.trim().isNotEmpty) {
        formData.fields.add(MapEntry('description', description.trim()));
      }
      for (final categoryId in categories) {
        formData.fields.add(MapEntry('categories', categoryId.toString()));
      }
      if (newIngredients.isNotEmpty) {
        final cleanIngredients = newIngredients
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        if (cleanIngredients.isNotEmpty) {
          formData.fields.add(
            MapEntry('new_ingredients', jsonEncode(cleanIngredients)),
          );
        }
      }
      if (discountsJson != null && discountsJson.trim().isNotEmpty) {
        final normalizedDiscounts = _normalizeOptionalJsonField(discountsJson);
        if (normalizedDiscounts != null) {
          formData.fields.add(MapEntry('discounts', normalizedDiscounts));
        }
      }
      if (deletedImageIds != null && deletedImageIds.trim().isNotEmpty) {
        final normalizedDeletedIds = _normalizeOptionalDeletedImageIdsJson(
          deletedImageIds,
        );
        if (normalizedDeletedIds != null) {
          formData.fields.add(
            MapEntry('deleted_image_ids', normalizedDeletedIds),
          );
        }
      }
      _addNormalizedJsonField(
        formData,
        key: 'modifier_groups',
        rawJson: modifierGroupsJson,
      );
      _addNormalizedJsonField(
        formData,
        key: 'recommendations',
        rawJson: recommendationsJson,
      );
      for (final image in newImages) {
        formData.files.add(
          MapEntry(
            'new_images',
            await MultipartFile.fromFile(image.path, filename: image.name),
          ),
        );
      }

      await _dio.patch(endpoint, data: formData);
    } catch (e) {
      final ex = ExceptionHandler.handleException(e);
      if (ex is NetworkException) throw ex;
      throw NetworkException(message: ex.toString());
    }
  }

  @override
  Future<VendorCreateModel> vendorCreate({
    required VendorCreateModel payload,
    XFile? profileImage,
    XFile? bannerImage,
    List<XFile> certificateFiles = const [],
  }) async {
    try {
      final formData = await _buildVendorFormData(
        payload: payload,
        profileImage: profileImage,
        bannerImage: bannerImage,
        certificateFiles: certificateFiles,
      );

      final response = await _dio.post(
        Constants.vendorsCreate,
        data: formData,
        options: Options(),
      );

      final bodyMap = response.data;
      if (bodyMap is Map<String, dynamic>) {
        return VendorCreateModel.fromJson(bodyMap);
      }
      throw NetworkException(message: 'Invalid vendor create response');
    } catch (e) {
      final ex = ExceptionHandler.handleException(e);
      if (ex is NetworkException) throw ex;
      throw NetworkException(message: ex.toString());
    }
  }

  @override
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
  }) async {
    try {
      final formData = await _buildVendorFormData(
        payload: payload,
        categoryIds: categoryIds,
        deletedCertificateIds: deletedCertificateIds,
        avgDeliveryTime: avgDeliveryTime,
        deleteLogo: deleteLogo,
        deleteBanner: deleteBanner,
        profileImage: profileImage,
        bannerImage: bannerImage,
        certificateFiles: certificateFiles,
      );

      final response = await _dio.patch(Constants.vendorsMe, data: formData);
      final bodyMap = response.data;
      if (bodyMap is Map<String, dynamic>) {
        return VendorMeModel.fromJson(bodyMap);
      }
      throw NetworkException(message: 'Invalid vendor update response');
    } catch (e) {
      final ex = ExceptionHandler.handleException(e);
      if (ex is NetworkException) throw ex;
      throw NetworkException(message: ex.toString());
    }
  }

  @override
  Future<VendorMediaPageResult> getVendorMedia({String? url}) async {
    final requestPath = url ?? Constants.vendorsVendorMedia;
    try {
      final response = await _dio.get<Map<String, dynamic>>(requestPath);
      final body = response.data;
      if (body == null) {
        throw NetworkException(message: 'Invalid vendor media response');
      }
      return VendorMediaPageResult.fromJson(Map<String, dynamic>.from(body));
    } catch (e) {
      final ex = ExceptionHandler.handleException(e);
      if (ex is NetworkException) throw ex;
      throw NetworkException(message: ex.toString());
    }
  }

  @override
  Future<void> uploadVendorMedia({
    required XFile videoFile,
    required String description,
  }) async {
    try {
      final formData = FormData();
      formData.files.add(
        MapEntry(
          'video',
          await MultipartFile.fromFile(
            videoFile.path,
            filename: videoFile.name,
          ),
        ),
      );
      formData.fields.add(MapEntry('description', description.trim()));
      await _dio.post(Constants.vendorsVendorMedia, data: formData);
    } catch (e) {
      final ex = ExceptionHandler.handleException(e);
      if (ex is NetworkException) throw ex;
      throw NetworkException(message: ex.toString());
    }
  }

  @override
  Future<void> updateVendorMediaDescription({
    required int mediaId,
    required String description,
  }) async {
    try {
      await _dio.patch(
        Constants.vendorsVendorMediaById(mediaId),
        data: {'description': description.trim()},
      );
    } catch (e) {
      final ex = ExceptionHandler.handleException(e);
      if (ex is NetworkException) throw ex;
      throw NetworkException(message: ex.toString());
    }
  }
}

// [compute] callbacklari top-level bo‘lishi kerak (isolate).
VendorMeModel _parseVendorMeInIsolate(Map<String, dynamic> json) {
  return VendorMeModel.fromJson(json);
}

List<VendorCategoryModel> _parseVendorCategoriesInIsolate(
  List<Map<String, dynamic>> rows,
) {
  return rows.map(VendorCategoryModel.fromJson).toList();
}

String? _normalizeOptionalJsonField(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return null;
  try {
    final decoded = jsonDecode(trimmed);
    return jsonEncode(decoded);
  } catch (_) {
    // discounts optional: noto'g'ri format bo'lsa field yuborilmaydi
    return null;
  }
}

void _addNormalizedJsonField(
  FormData formData, {
  required String key,
  required String? rawJson,
}) {
  if (rawJson == null || rawJson.trim().isEmpty) return;
  final normalized = _normalizeOptionalJsonField(rawJson);
  if (normalized == null) return;
  formData.fields.add(MapEntry(key, normalized));
}

String? _normalizeOptionalDeletedImageIdsJson(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return null;

  try {
    final decoded = jsonDecode(trimmed);
    if (decoded is List) {
      final ids = decoded
          .whereType<num>()
          .map((e) => e.toInt())
          .toList(growable: false);
      return jsonEncode(ids);
    }
    return null;
  } catch (_) {
    final csvParts = trimmed
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList(growable: false);
    if (csvParts.isNotEmpty) {
      final ids = <int>[];
      for (final part in csvParts) {
        final parsed = int.tryParse(part);
        if (parsed == null) {
          return null;
        }
        ids.add(parsed);
      }
      return jsonEncode(ids);
    }
    return null;
  }
}
