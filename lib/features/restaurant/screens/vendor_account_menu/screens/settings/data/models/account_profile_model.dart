class AccountProfileModel {
  const AccountProfileModel({
    required this.id,
    required this.username,
    required this.vendorName,
    required this.email,
    this.phoneNumber,
    this.userImageUrl,
  });

  final int id;
  final String username;
  final String vendorName;
  final String email;
  final String? phoneNumber;
  final String? userImageUrl;

  String get displayName {
    final name = vendorName.trim();
    return name.isNotEmpty ? name : username;
  }

  factory AccountProfileModel.fromJson(Map<String, dynamic> json) {
    return AccountProfileModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      username: (json['username'] ?? '').toString(),
      vendorName: (json['first_name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phoneNumber: json['phone_number']?.toString(),
      userImageUrl: json['user_image_url']?.toString(),
    );
  }
}
