import 'package:equatable/equatable.dart';

class AppVersionPlatformInfo extends Equatable {
  const AppVersionPlatformInfo({
    this.latestVersion,
    this.minSupportedVersion,
    this.updateUrl,
    this.isMandatory,
  });

  final String? latestVersion;
  final String? minSupportedVersion;
  final String? updateUrl;
  final bool? isMandatory;

  factory AppVersionPlatformInfo.fromJson(Map<String, dynamic> json) {
    return AppVersionPlatformInfo(
      latestVersion: json['latest_version']?.toString(),
      minSupportedVersion: json['min_supported_version']?.toString(),
      updateUrl: json['update_url']?.toString(),
      isMandatory: json['is_mandatory'] == true,
    );
  }

  @override
  List<Object?> get props => [
    latestVersion,
    minSupportedVersion,
    updateUrl,
    isMandatory,
  ];
}

class AppVersionModel extends Equatable {
  const AppVersionModel({this.android, this.ios});

  final AppVersionPlatformInfo? android;
  final AppVersionPlatformInfo? ios;

  factory AppVersionModel.fromJson(Map<String, dynamic> json) {
    AppVersionPlatformInfo? parse(dynamic raw) {
      if (raw is Map) {
        return AppVersionPlatformInfo.fromJson(
          Map<String, dynamic>.from(raw),
        );
      }
      return null;
    }

    return AppVersionModel(
      android: parse(json['android']),
      ios: parse(json['ios']),
    );
  }

  @override
  List<Object?> get props => [android, ios];
}
