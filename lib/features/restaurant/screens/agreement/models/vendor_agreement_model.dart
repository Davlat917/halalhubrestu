class VendorAgreementSectionModel {
  const VendorAgreementSectionModel({
    required this.id,
    required this.stepNumber,
    required this.title,
    required this.body,
    required this.isAccepted,
    this.acceptedAt,
  });

  final int id;
  final int stepNumber;
  final String title;
  final String body;
  final bool isAccepted;
  final String? acceptedAt;

  factory VendorAgreementSectionModel.fromJson(Map<String, dynamic> json) {
    return VendorAgreementSectionModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      stepNumber: (json['step_number'] as num?)?.toInt() ?? 0,
      title: (json['title'] as String?)?.trim() ?? '',
      body: (json['body'] as String?) ?? '',
      isAccepted: json['is_accepted'] == true,
      acceptedAt: json['accepted_at'] as String?,
    );
  }
}

class VendorAgreementModel {
  const VendorAgreementModel({
    required this.id,
    required this.status,
    required this.currentStep,
    required this.initials,
    required this.signedAt,
    required this.signedPdfUrl,
    required this.totalSteps,
    required this.sections,
  });

  final int id;
  final String status;
  final int currentStep;
  final String? initials;
  final String? signedAt;
  final String? signedPdfUrl;
  final int totalSteps;
  final List<VendorAgreementSectionModel> sections;

  factory VendorAgreementModel.fromJson(Map<String, dynamic> json) {
    final rawSections = json['sections'];
    final sections = <VendorAgreementSectionModel>[];
    if (rawSections is List) {
      for (final item in rawSections) {
        if (item is Map<String, dynamic>) {
          sections.add(VendorAgreementSectionModel.fromJson(item));
        } else if (item is Map) {
          sections.add(
            VendorAgreementSectionModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          );
        }
      }
    }
    return VendorAgreementModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      status: (json['status'] as String?)?.trim() ?? '',
      currentStep: (json['current_step'] as num?)?.toInt() ?? 0,
      initials: json['initials'] as String?,
      signedAt: json['signed_at'] as String?,
      signedPdfUrl: json['signed_pdf_url'] as String?,
      totalSteps: (json['total_steps'] as num?)?.toInt() ?? sections.length,
      sections: sections,
    );
  }
}
