import 'package:halalhub_restaurant/core/app_version/models/app_version_model.dart';

abstract class AppVersionRepository {
  Future<AppVersionModel> fetchVendorAppVersion();
}
